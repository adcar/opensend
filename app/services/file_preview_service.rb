# Handles file preview logic for different file types
class FilePreviewService
  PREVIEW_TYPES = {
    pdf: {
      extensions: %w[pdf],
      content_types: %w[application/pdf],
      viewer: :pdf
    },
    image: {
      extensions: %w[jpg jpeg png gif webp svg bmp],
      content_types: %w[image/jpeg image/png image/gif image/webp image/svg+xml image/bmp],
      viewer: :image
    },
    video: {
      extensions: %w[mp4 webm ogg mov],
      content_types: %w[video/mp4 video/webm video/ogg video/quicktime],
      viewer: :video
    },
    audio: {
      extensions: %w[mp3 wav ogg m4a],
      content_types: %w[audio/mpeg audio/wav audio/ogg audio/mp4],
      viewer: :audio
    },
    text: {
      extensions: %w[txt md markdown json xml yml yaml csv tsv log],
      content_types: %w[text/plain text/markdown application/json text/xml application/xml text/csv],
      viewer: :text
    },
    code: {
      extensions: %w[rb py js ts html css scss sass jsx tsx vue php java c cpp h hpp cs go rs swift kt],
      content_types: [],
      viewer: :code
    },
    spreadsheet: {
      extensions: %w[csv tsv],
      content_types: %w[text/csv text/tab-separated-values],
      viewer: :spreadsheet
    },
    office: {
      extensions: %w[doc docx xls xlsx ppt pptx odt ods odp],
      content_types: %w[
        application/msword
        application/vnd.openxmlformats-officedocument.wordprocessingml.document
        application/vnd.ms-excel
        application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
        application/vnd.ms-powerpoint
        application/vnd.openxmlformats-officedocument.presentationml.presentation
        application/vnd.oasis.opendocument.text
        application/vnd.oasis.opendocument.spreadsheet
        application/vnd.oasis.opendocument.presentation
      ],
      viewer: :office
    }
  }.freeze

  attr_reader :document

  def initialize(document)
    @document = document
  end

  def previewable?
    preview_type.present?
  end

  def preview_type
    @preview_type ||= detect_preview_type
  end

  def viewer
    return nil unless previewable?
    PREVIEW_TYPES[preview_type][:viewer]
  end

  def viewer_partial
    "previews/#{viewer}_viewer"
  end

  # Get raw content for text-based files
  def text_content(max_size: 500.kilobytes)
    return nil unless [:text, :code, :spreadsheet].include?(viewer)
    
    data = StorageService.retrieve(document.storage_key)
    return nil unless data
    return nil if data.bytesize > max_size
    
    data.force_encoding('UTF-8')
    data.scrub('�') # Replace invalid UTF-8 characters
  end

  # Parse CSV content into rows
  def csv_rows(max_rows: 1000)
    return nil unless viewer == :spreadsheet
    
    content = text_content
    return nil unless content
    
    require 'csv'
    delimiter = document.file_extension == 'tsv' ? "\t" : ","
    
    rows = []
    CSV.parse(content, col_sep: delimiter) do |row|
      rows << row
      break if rows.size >= max_rows
    end
    rows
  rescue CSV::MalformedCSVError
    nil
  end

  def syntax_language
    return nil unless viewer == :code
    
    lang_map = {
      'rb' => 'ruby', 'py' => 'python', 'js' => 'javascript', 
      'ts' => 'typescript', 'jsx' => 'javascript', 'tsx' => 'typescript',
      'html' => 'html', 'css' => 'css', 'scss' => 'scss',
      'json' => 'json', 'xml' => 'xml', 'yml' => 'yaml', 'yaml' => 'yaml',
      'php' => 'php', 'java' => 'java', 'c' => 'c', 'cpp' => 'cpp',
      'cs' => 'csharp', 'go' => 'go', 'rs' => 'rust', 'swift' => 'swift',
      'kt' => 'kotlin', 'vue' => 'vue'
    }
    lang_map[document.file_extension] || 'plaintext'
  end

  private

  def detect_preview_type
    ext = document.file_extension.downcase
    content_type = document.content_type.downcase

    # Check spreadsheet first (CSV can be both text and spreadsheet)
    if %w[csv tsv].include?(ext)
      return :spreadsheet
    end

    PREVIEW_TYPES.each do |type, config|
      return type if config[:extensions].include?(ext)
      return type if config[:content_types].include?(content_type)
    end

    nil
  end
end

