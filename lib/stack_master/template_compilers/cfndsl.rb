module StackMaster::TemplateCompilers
  class Cfndsl
    def self.require_dependencies
      require 'cfndsl'
    end

    def self.compile(template_dir, template, compile_time_parameters, _compiler_options = {})
      CfnDsl.disable_binding
      CfnDsl::ExternalParameters.defaults.clear # Ensure there's no leakage across invocations
      CfnDsl::ExternalParameters.defaults(compile_time_parameters.symbolize_keys)
      template_file_path = File.join(template_dir, template)
      ::CfnDsl.eval_file_with_extras(template_file_path).to_json
    end

    StackMaster::TemplateCompiler.register(:cfndsl, self)
  end
end
