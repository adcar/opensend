require 'json'
require 'rack'

# Load Rails
ENV['RAILS_ENV'] ||= 'production'
require_relative '../config/environment'

# Vercel Ruby Serverless Handler
class Handler
  def self.call(request)
    # Convert Vercel request to Rack env
    rack_env = build_rack_env(request)
    
    # Call Rails
    status, headers, body = Rails.application.call(rack_env)
    
    # Convert response
    response_body = ""
    body.each { |chunk| response_body += chunk }
    body.close if body.respond_to?(:close)
    
    {
      statusCode: status,
      headers: headers.reject { |k, _| k.downcase == 'transfer-encoding' },
      body: response_body
    }
  end
  
  def self.build_rack_env(request)
    env = {
      'REQUEST_METHOD' => request['method'] || 'GET',
      'SCRIPT_NAME' => '',
      'PATH_INFO' => request['path'] || '/',
      'QUERY_STRING' => request['query'] || '',
      'SERVER_NAME' => request.dig('headers', 'host')&.split(':')&.first || 'localhost',
      'SERVER_PORT' => '443',
      'rack.version' => Rack::VERSION,
      'rack.url_scheme' => 'https',
      'rack.input' => StringIO.new(request['body'] || ''),
      'rack.errors' => $stderr,
      'rack.multithread' => false,
      'rack.multiprocess' => false,
      'rack.run_once' => true
    }
    
    # Add HTTP headers
    (request['headers'] || {}).each do |key, value|
      rack_key = "HTTP_#{key.upcase.gsub('-', '_')}"
      env[rack_key] = value
    end
    
    # Special headers
    env['CONTENT_TYPE'] = request.dig('headers', 'content-type') if request.dig('headers', 'content-type')
    env['CONTENT_LENGTH'] = request.dig('headers', 'content-length') if request.dig('headers', 'content-length')
    env['HTTP_HOST'] = request.dig('headers', 'host')
    
    env
  end
end

# Export for Vercel
def handler(request:, context:)
  Handler.call(request)
rescue => e
  Rails.logger.error "Handler error: #{e.message}\n#{e.backtrace.first(10).join("\n")}"
  {
    statusCode: 500,
    headers: { 'Content-Type' => 'text/plain' },
    body: "Internal Server Error"
  }
end
