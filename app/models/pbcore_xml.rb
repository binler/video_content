class PbcoreXml < ActiveFedora::NokogiriDatastream
  set_terminology do |t|

    t.root(:path=>"pbcoreDescriptionDocument", :xmlns=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html", :schema=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html")

    t.pbcoreAnnotation{
      t.pbcoreAnnotation_type(:path=>{:attribute=>"annotationType"})
      t.pbcoreAnnotation_reference(:path=>{:attribute=>"ref"})
    }

    t.pbcoreIdentifier{
      t.pbcoreIdentifier_source(:path=>{:attribute=>"source"})
    }
    t.pbcoreTitle{
      t.pbcoreTitle_type(:path=>{:attribute=>"titleType"})
      t.pbcoreTitle_annotation(:path=>{:attribute=>"annotation"})
    }
    t.pbcoreAssetDate{
      t.pbcoreAssetDate_type(:path=>{:attribute=>"dateType"})
    }
    t.pbcoreDescription(:path=>"pbcoreDescription", :attributes=>{:descriptionType=>"Event", :descriptionTypeSource=>"pbcoreDescription/descriptionType", :ref=>"http://pbcore.org/vocabularies/pbcoreDescription/descriptionType#summary"})
    t.pbcoreSubject{
      t.pbcoreSubject_type(:path=>{:attribute=>"subjectType"})
      t.pbcoreSubject_source(:path=>{:attribute=>"source"})
    }
    t.pbcoreCreator(:ref=>[:pbcoreCreator_ref])
    t.pbcoreRightsSummary(:ref=>[:pbcoreRightsSummary_ref])
    t.pbcoreRightsSummary_ref(:path=>"pbcoreRightsSummary"){
      t.rightsSummary
      t.rightsLink
      t.rightsEmbedded
    }
    t.pbcoreCreator_ref(:path=>"pbcoreCreator"){
      t.creator{
	t.creator_annotation(:path=>{:attribute=>"annotation"})
	t.creator_reference(:path=>{:attribute=>"ref"})
	t.creator_affiliation(:path=>{:attribute=>"affiliation"})
      }
      t.creatorRole{
	t.creatorRole_source(:path=>{:attribute=>"source"})
	t.creatorRole_reference(:path=>{:attribute=>"ref"})
      }
    }
    t.pbcoreContributor_ref(:path=>"pbcoreContributor"){
      t.contributor
      t.contributorRole
    }
    t.pbcorePart{
      t.pbcoreIdentifier{
        t.pbcoreIdentifier_source(:path=>{:attribute=>"source"})
      }
      t.pbcoreTitle{
        t.pbcoreTitle_type(:path=>{:attribute=>"titleType"})
        t.pbcoreTitle_annotation(:path=>{:attribute=>"annotation"})
	t.pbcoreTitle_source(:path=>{:attribute=>"source"})
        t.pbcoreTitle_version(:path=>{:attribute=>"version"})
      }
      t.pbcoreDescription
      t.pbcoreContributor(:ref=>[:pbcoreContributor_ref])
      t.pbcoreRightsSummary(:ref=>[:pbcoreRightsSummary_ref])
    }
    t.pbcoreInstantiation(:ref=>[:pbcoreInstantiation_ref])
    t.instantiationPart(:ref=>[:instantiationPart_ref])

    t.pbcoreInstantiation_ref(:path=>"pbcoreInstantiation"){
      t.instantiationIdentifier(:ref=>[:instantiationIdentifier_ref])
      t.essenceTrack(:ref=>[:essenceTrack_ref])
      t.digital(:ref=>[:digital_ref])
      t.fileSize(:ref=>[:fileSize_ref])
      t.instantiationTracks
      t.instantiationPart
    }

    t.instantiationPart_ref(:path=>"instantiationPart"){
      t.instantiationAnnotation(:ref=>[:annotation_ref])
      t.instantiationLocation
      t.instantiationDate
      t.instantiationIdentifier(:ref=>[:instantiationIdentifier_ref])
      t.essenceTrack(:ref=>[:essenceTrack_ref])
      t.digital(:ref=>[:digital_ref])
      t.fileSize(:ref=>[:fileSize_ref])
      t.instantiationTracks
    }

    t.instantiationIdentifier_ref(:path=>"instantiationIdentifier"){
      t.instantiationIdentifier_source(:path=>{:attribute=>"source"})
    }
    t.essenceTrack_ref(:path=>"instantiationEssenceTrack"){
      t.essenceTrackDuration
      t.essenceTrackDataRate
      t.essenceTrackAspectRatio
    }
    t.digital_ref(:path=>"instantiationDigital"){
      t.digital_source(:path=>{:attribute=>"source"})
      t.digital_reference(:path=>{:attribute=>"ref"})
    }
    t.fileSize_ref(:path=>"instantiationFileSize"){
      t.fileSize_unit(:path=>{:attribute=>"unitOfMeassure"})
    }
    t.annotation_ref(:path=>"instantiationAnnotation"){
      t.annotation_type(:path=>{:attribute=>"annotationType"})
      t.annotation_reference(:path=>{:attribute=>"ref"})
    }
#
#    t.pbcoreInstantiation_ref(:path=>"pbcoreInstantiation"){
#      t.instantiationIdentifier{
#        t.instantiationIdentifier_source(:path=>{:attribute=>"source"})
#      }
#      t.essenceTrack(:path=>"instantiationEssenceTrack"){
#	t.essenceTrackDuration
#	t.essenceTrackDataRate
#	t.essenceTrackAspectRatio
#      }
#      t.digital(:path=>"instantiationDigital"){
#	t.digital_source(:path=>{:attribute=>"source"})
#	t.digital_reference(:path=>{:attribute=>"ref"})
#      }
#      t.fileSize(:path=>"instantiationFileSize"){
#	t.fileSize_reference(:path=>{:attribute=>"unitOfMeassure"})
#      }
#     t.instantiationTracks
#    }
  end

  def self.event_template
    builder = Nokogiri::XML::Builder.new do |xml|

      xml.pbcoreDescriptionDocument(:version=>"2.0", "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html",
        "xsi:schemaLocation"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html") {
      
        # Event ID
        xml.pbcoreIdentifier(:source=>"")

	# Event Title
        xml.pbcoreTitle(:titleType=>"", :annotation=>"")

	# Asset Creation Date
        xml.pbcoreAssetDate(:dateType=>"")

	# Description
        xml.pbcoreDescription(:descriptionType=>"Event", :descriptionTypeSource=>"pbcoreDescription/descriptionType", :ref=>"http://pbcore.org/vocabularies/pbcoreDescription/descriptionType#summary")

	# Creator
	xml.pbcoreCreator{
	  xml.creator(:annotation=>"", :ref=>"", :affiliation=>"")
	  xml.creatorRole(:source=>"", :ref=>"")
	}

	# Secorndary Creator
#	xml.pbcoreCreator{
#	  xml.creator
#	  xml.creatorRole(:source=>"", :ref=>"")
#	}

	# Source
	xml.pbcoreCreator{
	  xml.creator
	  xml.creatorRole(:source=>"", :ref=>"")
	}

	# Copyrights notice
	xml.pbcoreRightsSummary{
	  xml.rightsSummary
	  xml.rightsLink
	  xml.rightsEmbedded
	}

	# Keywords
	xml.pbcoreSubject(:subjectType=>"", :source=>"")

	# Model Release
	xml.pbcorePart{
	  xml.pbcoreIdentifier(:source=>"")
	  xml.pbcoreTitle(:titleType=>"", :source=>"", :version=>"", :annotation=>"")
	  xml.pbcoreDescription(:descriptionType=>"Event", :descriptionTypeSource=>"pbcoreDescription/descriptionType", :ref=>"http://pbcore.org/vocabularies/pbcoreDescription/descriptionType#summary")
	  xml.pbcoreContributor{
	    xml.contributor
	    xml.contributorRole
	  }
	  xml.pbcoreRightsSummary{
	    xml.rightsSummary
	    xml.rightsLink
	    xml.rightsEmbedded
	  }
	}
	
	# Contract Term
	xml.pbcorePart{
	  xml.pbcoreIdentifier(:source=>"")
	  xml.pbcoreTitle(:titleType=>"", :source=>"", :version=>"", :annotation=>"")
	  xml.pbcoreDescription(:descriptionType=>"Event", :descriptionTypeSource=>"pbcoreDescription/descriptionType", :ref=>"http://pbcore.org/vocabularies/pbcoreDescription/descriptionType#summary")
	  xml.pbcoreContributor{
	    xml.contributor
	    xml.contributorRole
	  }
	  xml.pbcoreRightsSummary{
	    xml.rightsSummary
	    xml.rightsLink
	    xml.rightsEmbedded
	  }
	}

	# Usage Rights / Permissions
	xml.pbcoreRightsSummary{
	  xml.rightsSummary
	  xml.rightsLink
	  xml.rightsEmbedded
	}

	xml.pbcoreAnnotation(:annotationType=>"", :ref=>"")

	# Child Elements
	xml.pbcoreInstantiation
      }
    end
    return builder.doc
  end

  def self.part_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.pbcorePart("xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html"){
	xml.pbcoreIdentifier(:source=>"")
	xml.pbcoreTitle(:titleType=>"", :source=>"", :version=>"", :annotation=>"")
	xml.pbcoreDescription(:descriptionType=>"Event", :descriptionTypeSource=>"pbcoreDescription/descriptionType", :ref=>"http://pbcore.org/vocabularies/pbcoreDescription/descriptionType#summary")
	xml.pbcoreContributor{
	  xml.contributor
	  xml.contributorRole
	}
	xml.pbcoreRightsSummary{
	  xml.rightsSummary
	  xml.rightsLink
	  xml.rightsEmbedded
	}
      }
    end
  end

  def self.digitalfile_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.pbcoreInstantiation("xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html"){

	# ID
	xml.instantiationIdentifier(:source=>"")

	# Annotation
	xml.instantiationAnnotation(:annotationType=>"", :ref=>"")

	# Duration, Data rate & Aspect ratio of the video
	xml.instantiationEssenceTrack{
	  xml.essenceTrackDuration
	  xml.essenceTrackDataRate
	  xml.essenceTrackAspectRatio
	}

	# File Format
	xml.instantiationDigital(:source=>"", :ref=>"")

	# File Size
	xml.instantiationFileSize(:unitOfMeassure=>"")

	# Audio and Video configuration
	xml.instantiationTracks

	# Derivatives (child element)
	xml.instantiationPart

      }
    end
    return builder.doc.root
  end

  def self.derivative_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.instantiationPart("xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html"){

	# ID
	xml.instantiationIdentifier(:source=>"")

	# Asset Creation Date
	xml.instantiationDate

	# Location
	xml.instantiationLocation

	# Duration, Data rate & Aspect ratio of the video
	xml.instantiationEssenceTrack{
	  xml.essenceTrackDuration
	  xml.essenceTrackDataRate
	  xml.essenceTrackAspectRatio
	}

	# File Format
	xml.instantiationDigital(:source=>"", :ref=>"")

	# File Size
	xml.instantiationFileSize(:unitOfMeassure=>"")

	# Audio and Video configuration
	xml.instantiationTracks

      }
    end
    return builder.doc.root
  end

  def self.creator_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.pbcoreCreator("xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html"){
	  xml.creator
	  xml.creatorRole(:source=>"", :ref=>"")
	}
    end
    return builder.doc.root
  end

  def insert_node(type, opts={})
    case type.to_sym
      when :event
        node = PbcoreXml.event_template
        nodeset = self.find_by_terms(:pbcoreDescriptionDocument)
      when :part
        node = PbcoreXml.part_template
        nodeset = self.find_by_terms(:pbcoreDescriptionDocument, :pbcorePart)
      when :degitalfile
        node = PbcoreXml.techdata_template
        nodeset = self.find_by_terms(:pbcoreDescriptionDocument, :pbcoreInstantiation)
      when :derivative
        node = PbcoreXml.derivative_template
        nodeset = self.find_by_terms(:pbcoreInstantiation, :instantiationPart)
      when :creator
        node = PbcoreXml.creator_template
        nodeset = self.find_by_terms(:pbcoreDescriptionDocument, :pbcoreCreator)
      else
        ActiveFedora.logger.warn("#{type} is not a valid argument for EadXml.insert_node")
        node = nil
        index = nil
    end
    unless nodeset.nil?
      if nodeset.empty?
        self.ng_xml.root.add_child(node)
        index = 0
      else
        nodeset.after(node)
        index = nodeset.length
      end
      self.dirty = true
    end
    return node, index
  end

  def remove_node(node_type, index)
    #TODO: Added code to remove any given node
    case node_type.to_sym
      when :digitalfile
        remove_node = self.find_by_terms(:pbcoreDescriptionDocument, :pbcoreInstantiation)[index.to_i]
      when :derivative
        remove_node = self.find_by_terms(:pbcoreInstantiation, :instantiationPart)[index.to_i]
      when :creator
        remove_node = self.find_by_terms(:pbcoreInstantiation, :pbcoreCreator)[index.to_i]
      when :part
        remove_node = self.find_by_terms(:pbcoreInstantiation, :pbcorePart)[index.to_i]
    end
    unless remove_node.nil?
      puts "Term to delete: #{remove_node.inspect}"
      remove_node.remove
      self.dirty = true
    end
  end
end
