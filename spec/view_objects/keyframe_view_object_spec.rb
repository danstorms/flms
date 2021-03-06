require 'spec_helper'

describe Flms::KeyframeViewObject do
  let(:test_keyframe) { create :keyframe,
                               scroll_start: 1, scroll_duration: 2,
                               width: 0.3, height: 0.4,
                               position_x: 0.5, position_y: 0.6,
                               margin_left: 0.1, margin_top: 0.2,
                               opacity: 0.7, scale: 0.8, blur: 0.9 }
  let!(:view_object) { Flms::KeyframeViewObject.new(test_keyframe) }

  describe 'styles' do
    it 'generates correct style attributes' do
      styles = view_object.styles
      expect(styles).to match 'left: 50.0%;'
      expect(styles).to match 'top: 60.0%;'
      expect(styles).to match 'opacity: 0.7;'
      expect(styles).to match 'filter: blur\(0.9\);'
    end
  end

  describe 'pinning' do
    it 'generates correct attributes' do
      styles = view_object.pinning(0.3, 0.4)
      expect(styles).to match "width: #{ test_keyframe.scale * 30 }%;"
      expect(styles).to match "height: #{ test_keyframe.scale * 40 }%;"
      expect(styles).to match "margin-left: #{ (test_keyframe.position_x * test_keyframe.scale * -30) + 10 }%"
      expect(styles).to match "margin-top: #{ (test_keyframe.position_y * test_keyframe.scale * -40) + 20 }%"
    end
  end

  describe 'style for attribute' do
    describe 'formatted as decimal' do
      it 'generates correct format for keyframe attributes' do
        stub_const 'Flms::KeyframeViewObject::KEYFRAME_ATTRIBUTE_FORMATTERS', { test: :format_as_decimal }
        expect(view_object.style_for_attribute(:test, 0.5)).to eql 'test: 0.5;'
      end
    end

    describe 'formatted as percent' do
      it 'generates correct format for keyframe attributes' do
        stub_const 'Flms::KeyframeViewObject::KEYFRAME_ATTRIBUTE_FORMATTERS', { test: :format_as_percent }
        expect(view_object.style_for_attribute(:test, 0.5)).to eql 'test: 50.0%;'
      end
    end

    describe 'formatted as px' do
      it 'generates correct format for keyframe attributes' do
        stub_const 'Flms::KeyframeViewObject::KEYFRAME_ATTRIBUTE_FORMATTERS', { test: :format_as_px }
        expect(view_object.style_for_attribute(:test, 50.0)).to eql 'test: 50.0px;'
      end
    end

    describe 'formatted as transform' do
      it 'generates correct format for keyframe attributes' do
        stub_const 'Flms::KeyframeViewObject::KEYFRAME_ATTRIBUTE_FORMATTERS', { test: :format_as_transform }
        expect(view_object.style_for_attribute(:test, 50.0)).to eql 'transform: test(50.0);'
      end
    end

    describe 'formatted as filter' do
      it 'generates correct format for keyframe attributes' do
        stub_const 'Flms::KeyframeViewObject::KEYFRAME_ATTRIBUTE_FORMATTERS', { test: :format_as_filter }
        expect(view_object.style_for_attribute(:test, 50.0)).to eql 'filter: test(50.0);'
      end
    end

    describe 'translation using KEYFRAME_ATTRIBUTE_NAMES_TO_CSS' do
      it 'translates :position_x to \'left\'' do
        expect(view_object.style_for_attribute(:position_x)).to eql 'left: 50.0%;'
      end

      it 'translates :position_y to \'top\'' do
        expect(view_object.style_for_attribute(:position_y)).to eql 'top: 60.0%;'
      end
    end

    it 'raises an error if an invalid attribute is specified' do
      expect { view_object.style_for_attribute(:a_bad_attribute) }.to raise_error
    end

    it 'generates correct style when attribute value is overridden' do
      expect(view_object.style_for_attribute(:width, -0.123)).to eql 'width: -12.3%;'
    end
  end

  describe 'attribute formatters' do
    describe 'format_as_decimal' do
      it 'converts correctly' do
        expect(view_object.format_as_decimal('name', -0.123)).to eql 'name: -0.123'
      end
    end

    describe 'format_as_percent' do
      it 'converts correctly' do
        expect(view_object.format_as_percent('name', -0.123)).to eql 'name: -12.3%'
      end

      it 'handles arbitrary number of decimal places' do
        expect(view_object.format_as_percent('name', 0.1)).to eql 'name: 10.0%'
        expect(view_object.format_as_percent('name', -0.123456)).to eql 'name: -12.3456%'
      end
    end

    describe 'format_as_transform' do
      it 'formats attribute correctly' do
        expect(view_object.format_as_transform('name', 'value')).to eql 'transform: name(value)'
      end
    end

    describe 'format_as_filter' do
      it 'formats attribute correctly' do
        expect(view_object.format_as_filter('name', 'value')).to eql 'filter: name(value)'
      end
    end

  end
end

