require 'net/http'
require 'json'

class StorageService
  class << self
    def store(file, key)
      adapter.store(file, key)
    end
    
    def retrieve(key)
      adapter.retrieve(key)
    end
    
    def delete(key)
      adapter.delete(key)
    end
    
    def url(key)
      adapter.url(key)
    end
    
    private
    
    def adapter
      if ENV["BLOB_READ_WRITE_TOKEN"].present?
        VercelBlobAdapter
      else
        LocalStorageAdapter
      end
    end
  end
  
  # Local file storage adapter for development
  module LocalStorageAdapter
    STORAGE_PATH = Rails.root.join("storage", "uploads")
    
    class << self
      def store(file, key)
        path = file_path(key)
        FileUtils.mkdir_p(File.dirname(path))
        
        if file.respond_to?(:read)
          File.binwrite(path, file.read)
          file.rewind if file.respond_to?(:rewind)
        else
          FileUtils.cp(file.path, path)
        end
        
        key
      end
      
      def retrieve(key)
        path = file_path(key)
        return nil unless File.exist?(path)
        File.binread(path)
      end
      
      def delete(key)
        path = file_path(key)
        FileUtils.rm_f(path)
        
        dir = File.dirname(path)
        FileUtils.rmdir(dir) if Dir.exist?(dir) && Dir.empty?(dir)
      end
      
      def url(key)
        "/storage/#{key}"
      end
      
      private
      
      def file_path(key)
        STORAGE_PATH.join(key)
      end
    end
  end
  
  # Vercel Blob Storage adapter for production
  module VercelBlobAdapter
    class << self
      def store(file, key)
        token = ENV.fetch("BLOB_READ_WRITE_TOKEN")
        
        content = file.respond_to?(:read) ? file.read : File.binread(file.path)
        file.rewind if file.respond_to?(:rewind)
        
        uri = URI("https://blob.vercel-storage.com/#{key}")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Put.new(uri)
        request["Authorization"] = "Bearer #{token}"
        request["x-api-version"] = "7"
        request["Content-Type"] = "application/octet-stream"
        request.body = content
        
        response = http.request(request)
        
        if response.code.to_i >= 200 && response.code.to_i < 300
          data = JSON.parse(response.body)
          data["url"]
        else
          Rails.logger.error "Vercel Blob upload failed: #{response.body}"
          raise "Failed to upload to Vercel Blob: #{response.code}"
        end
      end
      
      def retrieve(key)
        token = ENV.fetch("BLOB_READ_WRITE_TOKEN")
        
        # List blobs to find the URL
        list_uri = URI("https://blob.vercel-storage.com?prefix=#{URI.encode_www_form_component(key)}")
        
        http = Net::HTTP.new(list_uri.host, list_uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Get.new(list_uri)
        request["Authorization"] = "Bearer #{token}"
        
        response = http.request(request)
        return nil unless response.code.to_i == 200
        
        data = JSON.parse(response.body)
        blob = data["blobs"]&.find { |b| b["pathname"] == key }
        return nil unless blob
        
        # Download the file
        download_uri = URI(blob["url"])
        download_response = Net::HTTP.get_response(download_uri)
        download_response.code.to_i == 200 ? download_response.body : nil
      end
      
      def delete(key)
        token = ENV.fetch("BLOB_READ_WRITE_TOKEN")
        
        uri = URI("https://blob.vercel-storage.com/delete")
        
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(uri)
        request["Authorization"] = "Bearer #{token}"
        request["Content-Type"] = "application/json"
        request.body = { urls: [key] }.to_json
        
        http.request(request)
      end
      
      def url(key)
        # Return a placeholder - actual URL comes from blob metadata
        "https://blob.vercel-storage.com/#{key}"
      end
    end
  end
end
