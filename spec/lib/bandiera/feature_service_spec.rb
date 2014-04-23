require 'spec_helper'

describe Bandiera::FeatureService do
  let(:db) { Bandiera::Db.connection }
  subject { Bandiera::FeatureService.new }

  describe '#add_group' do
    it 'adds a new group' do
      expect(db[:groups]).to be_empty
      subject.add_group('burgers')
      expect(db[:groups].select_map(:name)).to eq(['burgers'])
    end
  end

  describe '#add_feature' do
    let(:feature_hash) { { name: 'name', group: 'group', description: '', enabled: true } }
    let(:feature) { double('feature') }

    before do
      subject.stub(:add_features).and_return([feature])
    end

    it 'calls #add_features' do
      subject
        .should_receive(:add_features)
        .with([feature_hash])

      subject.add_feature(feature_hash)
    end

    it 'returns the created feature' do
      result = subject.add_feature(feature_hash)

      expect(result).to eq(feature)
    end
  end

  describe '#add_features' do
    let(:features) do
      [
        { name: 'feature_name', group: 'feature_group', description: '', enabled: true },
        { name: 'feature_name2', group: 'feature_group', description: '', enabled: true }
      ]
    end

    context 'when a group exists' do
      before do
        db[:groups] << { name: 'feature_group' }
      end

      it 'create features' do
        expect do
          subject.add_features(features)
        end.to change{
          db[:features].count
        }.by(2)
      end

      it 'does not create a new group' do
        expect do
          subject.add_features(features)
        end.to_not change { db[:groups].count }
      end

      it 'returns a list of created features' do
        returned_features = subject.add_features(features)

        expect(returned_features).to be_an_instance_of(Array)
        expect(returned_features.first).to be_an_instance_of(Bandiera::Feature)
        expect(returned_features.size).to eq(2)
      end

      context 'when one or more of the features already exists' do
        let(:group_id) { db[:groups].first[:id] }
        let(:feature_name) { 'feature_name' }

        before do
          pre_existing_feature = {
            name: feature_name,
            description: '',
            enabled: false,
            group_id: group_id
          }

          db[:features] << pre_existing_feature
        end

        it 'updates the existing features' do
          expect do
            subject.add_features(features)
          end.to change {
            db[:features].first(group_id: group_id, name: feature_name)[:enabled]
          }.from(false).to(true)
        end
      end
    end

    context "when a group doesn't exist" do
      it 'creates the group' do
        expect do
          subject.add_features(features)
        end.to change {
          db[:groups].count
        }.from(0).to(1)
      end

      it 'creates the features' do
        expect do
          subject.add_features(features)
        end.to change {
          db[:features].count
        }.from(0).to(2)
      end
    end
  end

  describe '#remove_feature' do
    context "when the group doesn't exist" do
      it 'raises a RecordNotFound error' do
        expect do
          subject.remove_feature('burgers', 'foo')
        end.to raise_error(Bandiera::FeatureService::RecordNotFound)
      end
    end

    context "when the feature doesn't exist" do
      before do
        db[:groups] << { name: 'group1' }
      end

      it 'raises a RecordNotFound error' do
        expect do
          subject.remove_feature('group1', 'foo')
        end.to raise_error(Bandiera::FeatureService::RecordNotFound)
      end
    end

    context 'when both the group and the feature exist' do
      before do
        db[:groups] << { name: 'group' }
        db[:features] << { name: 'feat', group_id: db[:groups].first[:id], description: '', enabled: false }
      end

      it 'removes a feature record' do
        expect do
          subject.remove_feature('group', 'feat')
        end.to change {
          db[:features].count
        }.from(1).to(0)
      end

      it 'does not remove the group' do
        expect do
          subject.remove_feature('group', 'feat')
        end.to_not change {
          db[:groups].count
        }
      end
    end
  end

  describe '#update_feature' do
    context "when the group doesn't exist" do
      it 'raises a RecordNotFound error' do
        expect do
          subject.update_feature('my_group', 'my_feature', {})
        end.to raise_error(Bandiera::FeatureService::RecordNotFound)
      end
    end

    context "when the feature doesn't exist" do
      before do
        db[:groups] << { name: 'my_group' }
      end

      it 'raises a RecordNotFound error' do
        expect do
          subject.update_feature('my_group', 'my_feature', {})
        end.to raise_error(Bandiera::FeatureService::RecordNotFound)
      end
    end

    context 'when the group/feature does exist' do
      before do
        db[:groups] << { name: 'group' }
        db[:features] << { name: 'feat', group_id: db[:groups].first[:id] }
      end

      it 'updates the feature' do
        expect do
          subject.update_feature('group', 'feat',  name: 'updated')
        end.to change {
          db[:features].first[:name]
        }.from('feat').to('updated')
      end

      it 'returns the updated feature' do
        expect(
          subject.update_feature('group', 'feat',  name: 'updated')
        ).to be_an_instance_of(Bandiera::Feature)
      end
    end
  end

  describe '#get_groups' do
    before do
      db[:groups] << { name: 'group1' }
      db[:groups] << { name: 'group2' }
    end

    it 'gets a list of all groups' do
      expect(subject.get_groups).to eq(%w(group1 group2))
    end
  end

  describe '#get_group_features' do
    let(:first_group) { db[:groups].filter(name: 'group_name').first }
    let(:second_group) { db[:groups].filter(name: 'something_else').first }

    before do
      db[:groups] << { name: 'group_name' }
      db[:groups] << { name: 'something_else' }

      db[:features] << { name: 'feature1', group_id: first_group[:id] }
      db[:features] << { name: 'feature2', group_id: first_group[:id] }
      db[:features] << { name: 'wibble', group_id: second_group[:id] }
    end

    context 'when the group exists' do
      it 'gets all features for a group' do
        features = subject.get_group_features(first_group[:name])

        expect(features).to be_an_instance_of(Array)
        expect(features.size).to eq(2)
        expect(features.first).to be_an_instance_of(Bandiera::Feature)

        names = features.map(&:name)
        expect(names).to eq(%w(feature1 feature2))
      end
    end

    context "when the group doesn't exist" do
      it 'raises a Bandiera::FeatureService::RecordNotFound error' do
        expect do
          subject.get_group_features('burgers')
        end.to raise_error(Bandiera::FeatureService::RecordNotFound)
      end
    end
  end

  describe '#get_feature' do
    context 'when both the group and the feature exists' do
      before do
        db[:groups] << { name: 'group1' }
        db[:features] << { name: 'feature1', group_id: db[:groups].first[:id] }
      end

      it 'returns the feature' do
        feature = subject.get_feature('group1', 'feature1')
        expect(feature).to be_an_instance_of(Bandiera::Feature)
        expect(feature.name).to eq 'feature1'
      end
    end

    context "when the group doesn't exist" do
      it 'raises a Bandiera::FeatureService::RecordNotFound error' do
        expect do
          subject.get_feature('cheeses', 'stilton')
        end.to raise_error(Bandiera::FeatureService::RecordNotFound)
      end
    end

    context "when the feature doesn't exist" do
      before do
        db[:groups] << { name: 'cheeses' }
      end

      it 'raises a Bandiera::FeatureService::RecordNotFound error' do
        expect do
          subject.get_feature('cheeses', 'stilton')
        end.to raise_error(Bandiera::FeatureService::RecordNotFound)
      end
    end
  end
end
