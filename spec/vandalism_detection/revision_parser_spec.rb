require 'spec_helper'

describe Wikipedia::VandalismDetection::RevisionParser do
  let(:xml) { load_file('revision_simplified.xml') }
  let(:revision) { subject.parse(xml) }

  let(:expected_revision) do
    build(
      :empty_revision,
      id:          'id1',
      parent_id:   'parentid1',
      timestamp:   'time1',
      contributor: 'ip1',
      comment:     'comment 1',
      text:        'text 1',
      sha1:        'hash1'
    )
  end

  describe '#parse' do
    it 'returns a Wikipedia::Revision object' do
      expect(revision).to be_a Wikipedia::VandalismDetection::Revision
    end

    it 'returns a revision with only the configured properties' do
      revision = subject.parse(xml, only: %i[id parent_id])

      %i[id parent_id].each do |attribute|
        expect(revision.send(attribute)).not_to be_nil
      end

      %i[timestamp contributor sha1].each do |attribute|
        expect(revision.send(attribute)).to be_nil
      end

      %i[comment text].each do |attribute|
        expect(revision.send(attribute)).to eq ''
      end
    end
  end

  describe 'a single revison content parsing' do
    it 'can read a single revsion dump text input' do
      expect(revision).to_not be_nil
    end

    %i[id timestamp contributor comment text sha1].each do |attribute|
      it "has the expected #{attribute}" do
        expect(revision.send(attribute)).to eq expected_revision.send(attribute)
      end
    end
  end
end
