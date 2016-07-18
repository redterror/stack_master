module StackMaster::TemplateCompilers
  class Cfndsl
    def self.require_dependencies
      require 'cfndsl'
    end

    def self.compile(template_file_path, compile_time_parameters, compiler_options = {})
      CfnDsl.disable_binding
      CfnDsl::ExternalParameters.defaults.clear # Ensure there's no leakage across invocations
      CfnDsl::ExternalParameters.defaults(compile_time_parameters.symbolize_keys)

      extras = Array(compiler_options["external_parameters"])
      ::CfnDsl.eval_file_with_extras(template_file_path, extras).to_json
    end

    StackMaster::TemplateCompiler.register(:cfndsl, self)
  end
end
