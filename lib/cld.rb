require "cld/version"
require "ffi"

module CLD
  extend FFI::Library

  def self.lib_path
    spec = Gem.loaded_specs["cld2"]
    shared_object = "libcld2.#{RbConfig::CONFIG["DLEXT"]}"
    candidates = [
      # Built by gem installation process
      File.join(spec.extension_dir, shared_object),
      # Built by local development process using `rake compile`
      File.join(File.expand_path(__dir__), "..", "ext", "cld", shared_object)
    ]
    candidates.find { |path| File.exist?(path) }
  end

  ffi_lib(lib_path)

  def self.detect_language(text, is_plain_text=true)
    result = detect_language_ext(text.to_s, is_plain_text)
    Hash[ result.members.map {|member| [member.to_sym, result[member]]} ]
  end

  private

  class ReturnValue < FFI::Struct
    layout :name, :string, :code, :string, :reliable, :bool
  end
  
  attach_function "detect_language_ext", "detectLanguageThunkInt", [:buffer_in, :bool], ReturnValue.by_value
end
