require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::SameEditor do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    context 'when both contributors are given' do
      it 'returns 1.0 in case of the same previous editor' do
        editor = 'Peter'
        old_rev = build(:old_revision, contributor: editor)
        new_rev = build(:new_revision, contributor: editor)
        edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

        expect(subject.calculate(edit)).to eq 1
      end

      it 'returns 0.0 in case of another previous editor' do
        old_rev = build(:old_revision, contributor: '137.163.16.199')
        new_rev = build(:new_revision, contributor: 'Peter')
        edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

        expect(subject.calculate(edit)).to eq 0
      end
    end

    context 'when previous contributor is not present' do
      context 'in case of the same previous editor' do
        it 'requests the user from Wikipedia API and returns 1' do
          # contributor: TOmaxer
          old_rev = build(:old_revision, id: '324557983', contributor: nil)
          new_rev = build(
            :new_revision,
            id: '329962649',
            parent_id: '324557983',
            contributor: 'Tomaxer'
          )

          edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

          expect(subject.calculate(edit)).to eq 1
        end
      end

      context 'in case of another previous editor' do
        it 'requests the user from Wikipedia API and returns 0' do
          # 137.163.16.199
          old_rev = build(:old_revision, id: '328774110', contributor: nil)
          # ClueBot
          new_rev = build(:new_revision, id: '328774035', parent_id: '328774110')
          edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

          expect(subject.calculate(edit)).to eq 0
        end
      end

      context 'if old reivision is not available anymore' do
        it 'returns missing' do
          # to get api call, see:
          # https://en.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=timestamp&revids=325218985
          # <rev revid="325218985"/>

          old_rev = build(:old_revision, id: '325218985', contributor: nil)
          new_rev = build(:new_revision, id: '326980599', parent_id: '325218985')
          edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

          expect(subject.calculate(edit)).to eq Features::MISSING_VALUE
        end
      end
    end
  end
end
