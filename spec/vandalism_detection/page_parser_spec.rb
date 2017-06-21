require 'spec_helper'

describe Wikipedia::VandalismDetection::PageParser do
  let(:xml)  { load_file('vandalism_on_wikipedia.xml') }
  let(:page) { subject.parse(xml) }

  let(:simplified_xml) { load_file('vandalism_on_wikipedia_simplified.xml') }
  let(:simplified_page) { subject.parse(simplified_xml) }

  describe 'parser structure' do
    describe '#parse' do
      it 'returns a Wikipedia::Page object' do
        expect(page).to be_a Wikipedia::VandalismDetection::Page
      end

      it 'returns a Wikipedia::Page with the right number of revisions' do
        expect(page.revisions.count).to eq 5
      end
    end
  end

  describe 'a single page content parsing' do
    let(:revision_a) { build(:empty_revision, id: '398880281') }
    let(:revision_b) { build(:empty_revision, id: '398880502', parent_id: '398880281') }
    let(:revision_c) { build(:empty_revision, id: '398883278', parent_id: '398880502') }
    let(:revision_d) { build(:empty_revision, id: '398883675', parent_id: '398883278') }
    let(:revision_e) { build(:empty_revision, id: '398885233', parent_id: '398883675') }

    let(:revisions) do
      {
        revision_a.id => revision_a,
        revision_b.id => revision_b,
        revision_c.id => revision_c,
        revision_d.id => revision_d,
        revision_e.id => revision_e
      }
    end

    it 'can read a single page dump text input' do
      expect(page).to_not be_nil
    end

    it 'has a title' do
      expect(page.title).to eq 'Vandalism on Wikipedia'
    end

    it 'has an id' do
      expect(page.id).to eq '29753790'
    end

    describe 'page’s revisions' do
      it 'has the right number of revisions' do
        expect(page.revisions.count).to eq 5
      end

      it 'has revisions each with the right id' do
        page_revisions = page.revisions

        page_revisions.each do |key, value|
          expect(value.id).to eq revisions[key].id
        end
      end

      it 'has revisions each with the right parent_id' do
        page_revisions = page.revisions

        page_revisions.each do |key, value|
          expect(value.parent_id).to eq revisions[key].parent_id
        end
      end

      it 'has revisions each with the right text' do
        revision_a = build(:empty_revision, id: '1', text: "text\n\n\n        1\n\n      ")
        revision_b = build(:empty_revision, id: '2', text: 'text 2')
        revision_c = build(:empty_revision, id: '3', text: 'text 3')
        revision_d = build(:empty_revision, id: '4', text: 'text 4')
        revision_e = build(:empty_revision, id: '5', text: 'text 5')

        revisions = {
          revision_a.id => revision_a,
          revision_b.id => revision_b,
          revision_c.id => revision_c,
          revision_d.id => revision_d,
          revision_e.id => revision_e
        }

        simplified_page.revisions.each do |key, value|
          expect(value.text).to eq revisions[key].text
        end
      end

      it 'has revisions each with the right comment' do
        revision_a = build(:empty_revision, id: '1', comment: "comment\n\n        1\n\n      ")
        revision_b = build(:empty_revision, id: '2', comment: 'comment 2')
        revision_c = build(:empty_revision, id: '3')
        revision_d = build(:empty_revision, id: '4')
        revision_e = build(:empty_revision, id: '5', comment: 'comment 3')

        revisions = {
          revision_a.id => revision_a,
          revision_b.id => revision_b,
          revision_c.id => revision_c,
          revision_d.id => revision_d,
          revision_e.id => revision_e
        }

        simplified_page.revisions.each do |key, value|
          expect(value.comment).to eq revisions[key].comment
        end
      end

      describe 'contributor properties' do
        let(:revision_a) { build(:empty_revision, id: '1', contributor: '1') }
        let(:revision_b) { build(:empty_revision, id: '2', contributor: '10', contributor_username: 'user') }
        let(:revision_c) { build(:empty_revision, id: '3', contributor: '11', contributor_username: 'user') }
        let(:revision_d) { build(:empty_revision, id: '4', contributor: '12', contributor_username: 'user') }
        let(:revision_e) { build(:empty_revision, id: '5', contributor: '2') }

        let(:revisions) do
          {
            revision_a.id => revision_a,
            revision_b.id => revision_b,
            revision_c.id => revision_c,
            revision_d.id => revision_d,
            revision_e.id => revision_e
          }
        end

        it 'has revisions each with the right contributor id' do
          simplified_page.revisions.each do |key, value|
            expect(value.contributor_id).to eq revisions[key].contributor_id
          end
        end

        it 'has revisions each with the right contributor ip' do
          simplified_page.revisions.each do |key, value|
            expect(value.contributor_ip).to eq revisions[key].contributor_ip
          end
        end

        it 'has revisions each with the right contributor username' do
          simplified_page.revisions.each do |key, value|
            username = revisions[key].contributor_username
            expect(value.contributor_username).to eq username
          end
        end
      end

      it 'has revisions each with the right timestamp' do
        revision_a = build :empty_revision, id: '1', timestamp: 'time 1'
        revision_b = build :empty_revision, id: '2', timestamp: 'time 2'
        revision_c = build :empty_revision, id: '3', timestamp: 'time 3'
        revision_d = build :empty_revision, id: '4', timestamp: 'time 4'
        revision_e = build :empty_revision, id: '5', timestamp: 'time 5'

        revisions = {
          revision_a.id => revision_a,
          revision_b.id => revision_b,
          revision_c.id => revision_c,
          revision_d.id => revision_d,
          revision_e.id => revision_e
        }

        simplified_page.revisions.each do |key, value|
          expect(value.timestamp).to eq revisions[key].timestamp
        end
      end

      it 'has revisions each with the right sha1 hash' do
        revision_a = build :empty_revision, id: '1', sha1: 'hash1'
        revision_b = build :empty_revision, id: '2', sha1: 'hash2'
        revision_c = build :empty_revision, id: '3', sha1: 'hash3'
        revision_d = build :empty_revision, id: '4', sha1: 'hash4'
        revision_e = build :empty_revision, id: '5', sha1: 'hash5'

        revisions = {
          revision_a.id => revision_a,
          revision_b.id => revision_b,
          revision_c.id => revision_c,
          revision_d.id => revision_d,
          revision_e.id => revision_e
        }

        simplified_page.revisions.each do |key, value|
          expect(value.sha1).to eq revisions[key].sha1
        end
      end
    end
  end
end
