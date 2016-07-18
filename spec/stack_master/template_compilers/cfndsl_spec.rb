RSpec.describe StackMaster::TemplateCompilers::Cfndsl do

  let(:compile_time_parameters) { {'InstanceType' => 't2.medium'} }
  let(:compiler_options) { {} }

  before(:all) { described_class.require_dependencies }

  describe '.compile' do
    def compile
      described_class.compile(template_file_path, compile_time_parameters, compiler_options)
    end

    context 'valid cfndsl template' do
      let(:template_file_path) { 'spec/fixtures/templates/rb/cfndsl/sample.rb' }
      let(:valid_compiled_json_path) { 'spec/fixtures/templates/rb/cfndsl/sample.json' }

      it 'produces valid JSON' do
        valid_compiled_json = File.read(valid_compiled_json_path)
        expect(JSON.parse(compile)).to eq(JSON.parse(valid_compiled_json))
      end
    end

    context 'with compile time parameters' do
      let(:template_file_path) { 'spec/fixtures/templates/rb/cfndsl/sample-ctp.rb' }
      let(:valid_compiled_json_path) { 'spec/fixtures/templates/rb/cfndsl/sample-ctp.json' }

      it 'produces valid JSON' do
        valid_compiled_json = File.read(valid_compiled_json_path)
        expect(JSON.parse(compile)).to eq(JSON.parse(valid_compiled_json))
      end

      context 'compiling multiple times' do
        let(:compile_time_parameters) { {'InstanceType' => 't2.medium', 'DisableApiTermination' => 'true'} }
        let(:template_file_path) { 'spec/fixtures/templates/rb/cfndsl/sample-ctp-repeated.rb' }

        it 'does not leak compile time params across invocations' do
          expect {
            compile_time_parameters.delete("DisableApiTermination")
          }.to change { JSON.parse(compile)["Resources"]["MyInstance"]["Properties"]["DisableApiTermination"] }.from('true').to(nil)
        end
      end
    end

    context 'with external_parameters' do
      let(:template_file_path) { 'spec/fixtures/templates/rb/cfndsl/sample.rb' }
      let(:compiler_options)  { { "external_parameters" => 'foo/bar.yml' } }

      it 'tells CfnDsl to use an external parameter file' do
        expect(CfnDsl).to receive(:eval_file_with_extras).with(anything, ['foo/bar.yml'])
        compile
      end
    end
  end
end
