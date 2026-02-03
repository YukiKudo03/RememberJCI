# frozen_string_literal: true

PaperTrail.config.object_changes_adapter = PaperTrail::Serializers::JSON
PaperTrail.serializer = PaperTrail::Serializers::JSON
