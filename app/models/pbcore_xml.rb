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
    t.pbcoreCoverage{
      t.coverage{
	t.coverage_source(:path=>{:attribute=>"source"})
	t.coverage_reference(:path=>{:attribute=>"ref"})
      }
      t.coverageType
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
	t.creatorRole_annotation(:path=>{:attribute=>"annotation"})
      }
    }
    t.pbcoreContributor_ref(:path=>"pbcoreContributor"){
      t.contributor
      t.contributorRole
    }
    t.pbcorePart_ref(:path=>"pbcorePart"){
      t.pbcoreIdentifier{
        t.pbcoreIdentifier_source(:path=>{:attribute=>"source"})
      }
      t.pbcoreTitle{
        t.pbcoreTitle_type(:path=>{:attribute=>"titleType"})
      }
      t.pbcoreDescription
      t.pbcoreRelation(:path=>"pbcoreRelation"){
	t.pbcoreRelationType
	t.pbcoreRelationIdentifier
      }
      t.pbcoreContributor(:ref=>[:pbcoreContributor_ref])
      t.pbcoreCreator(:ref=>[:pbcoreCreator_ref])
      t.pbcoreRightsSummary(:ref=>[:pbcoreRightsSummary_ref])
      t.pbcoreAnnotation{
#        t.text(:path=>'text()')
        t.annotation_type(:path=>{:attribute=>"annotationType"})
        t.annotation_reference(:path=>{:attribute=>"ref"})
      }
      t.pbcoreInstantiation(:ref=>[:pbcoreInstantiation_ref])
      t.pbcoreAssetType{
	t.text(:path=>'text()')
        t.pbcoreAssetType_annotation(:path=>{:attribute=>"annotation"})
        t.pbcoreAssetType_reference(:path=>{:attribute=>"ref"})
      }
    }

    t.pbcorePart(:ref=>[:pbcorePart_ref]){
      t.pbcorePart(:ref=>[:pbcorePart_ref]){
	t.pbcorePart(:ref=>[:pbcorePart_ref])
      }
    }
    
    t.pbcoreContributor(:ref=>[:pbcoreContributor_ref])

    t.pbcoreInstantiation_ref(:path=>"pbcoreInstantiation"){
      t.instantiationDate
      t.instantiationLocation
      t.instantiationAnnotation{
        t.text(:path=>'text()')
        t.annotation_type(:path=>{:attribute=>"annotationType"})
        t.annotation_reference(:path=>{:attribute=>"ref"})
      }
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
      t.annotation(:path=>"text()")
      t.annotation_type(:path=>{:attribute=>"annotationType"})
      t.annotation_reference(:path=>{:attribute=>"ref"})
    }
#    t.pbcoreAssetType(:ref=>[:pbcoreAssetType_ref])
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

	xml.pbcoreCoverage{
	  xml.coverage(:source=>"", :ref=>"")
	  xml.coverageType("spatial")
	}

	# Description
        xml.pbcoreDescription(:descriptionType=>"Event", :descriptionTypeSource=>"pbcoreDescription/descriptionType", :ref=>"http://pbcore.org/vocabularies/pbcoreDescription/descriptionType#summary")

	# Creator
	xml.pbcoreCreator{
	  xml.creator(:affiliation=>"", :ref=>"", :annotation=>"")
	  xml.creatorRole(:source=>"", :ref=>"", :annotation=>"")
	}

	# Keywords
	xml.pbcoreSubject(:subjectType=>"", :source=>"")

	# Production Company
	xml.pbcorePart{
	  xml.pbcoreIdentifier(:source=>"")
	  xml.pbcoreTitle("PRODUCTION COMPANY DETAILS")
	  xml.pbcoreDescription
	  xml.pbcoreCreator{
	    xml.creator
	    xml.creatorRole("producer")
	  }

	  #Contract
	  xml.pbcoreRightsSummary{
	    xml.rightsSummary
	  }

	  # Usage rights
	  xml.pbcoreRightsSummary{
	    xml.rightsSummary
	  }

	  # Comments about the production company [and | or] contract and rights
          xml.pbcoreAnnotation
	}

	#Speaker Section
	xml.pbcorePart{

	  xml.pbcoreIdentifier(:source=>"")
	  xml.pbcoreTitle("SPEAKER DETAILS")
	  xml.pbcoreDescription

	  xml.pbcoreContributor{
	    xml.contributor
	    xml.contributorRole("speaker")
	  }
	  
	  xml.pbcoreRightsSummary{
	    xml.rightsSummary
	  }
	  
	  xml.pbcoreAnnotation
	}
	
	# Link Section
	xml.pbcorePart{
	  xml.pbcoreIdentifier(:source=>"")
	  xml.pbcoreTitle("ASSET LINK")
	  xml.pbcoreDescription
	  xml.pbcoreAssetType(:ref=>"", :annotation=>"")
	}
	# Child Elements
#	xml.pbcoreInstantiation
      }
    end
    return builder.doc
  end

  def self.part_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.pbcorePart("xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html"){
	xml.pbcoreIdentifier(:source=>"")
	xml.pbcoreTitle("SPEAKER DETAILS")
	xml.pbcoreDescription
	xml.pbcoreContributor{
	  xml.contributor
	  xml.contributorRole("speaker")
	}
	xml.pbcoreRightsSummary{
	  xml.rightsSummary
	}
        xml.pbcoreAnnotation
      }
    end
    return builder.doc.root
  end

  def self.assetlink_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.pbcorePart("xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html"){
	xml.pbcoreIdentifier(:source=>"")
	xml.pbcoreTitle("ASSET LINK")
	xml.pbcoreDescription
	xml.pbcoreAssetType(:ref=>"", :annotation=>"")
      }
    end
    return builder.doc.root
  end

  def self.master_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.pbcorePart("xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html"){
	xml.pbcoreIdentifier(:source=>"")
	xml.pbcoreTitle("MASTER DETAILS")
	xml.pbcoreDescription
	
	#Archival Section
	xml.pbcorePart{
	  xml.pbcoreIdentifier(:source=>"", :annotation=>"archival_code")
	  xml.pbcoreTitle
	  xml.pbcoreDescription(:annotation=>"archival_description")
	  xml.pbcoreRelation{
            xml.pbcoreRelationType
            xml.pbcoreRelationIdentifier(:annotation=>"accession_number")
          }
	}
	xml.pbcoreCreator{
	  xml.creator(:affiliation=>"", :ref=>"", :annotation=>"creator")
	  xml.creatorRole
	}
	xml.pbcoreCreator{
	  xml.creator(:affiliation=>"", :ref=>"", :annotation=>"owner")
	  xml.creatorRole
	}
	xml.pbcoreInstantiation{
	  # ID
	  xml.instantiationIdentifier(:source=>"")
	  xml.instantiationDate
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
	  # Description
	  xml.instantiationAnnotation(:annotationType=>"", :ref=>"")
	  # Retention Schedule
	  xml.instantiationAnnotation(:annotationType=>"", :ref=>"")
	}
	# Link Section
	xml.pbcorePart{
	  xml.pbcoreIdentifier(:source=>"")
	  xml.pbcoreTitle("ASSET LINK")
	  xml.pbcoreDescription
	  xml.pbcoreAssetType(:ref=>"", :annotation=>"")
	}
	# Derivatives (child element)
	xml.pbcorePart
      }
    end
    return builder.doc.root
  end

  def self.derivative_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.pbcorePart("xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html"){
	xml.pbcoreIdentifier(:source=>"")
	xml.pbcoreTitle("DERIVATIVE DETAILS")
	xml.pbcoreDescription
	
	xml.pbcoreCreator{
	  xml.creator(:affiliation=>"", :ref=>"", :annotation=>"creator")
	  xml.creatorRole
	}
	xml.pbcoreCreator{
	  xml.creator(:affiliation=>"", :ref=>"", :annotation=>"owner")
	  xml.creatorRole
	}
        xml.pbcoreInstantiation{
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
	  # Decription
	  xml.instantiationAnnotation(:annotationType=>"", :ref=>"")
	  # Retention Schedule
	  xml.instantiationAnnotation(:annotationType=>"", :ref=>"")
	}
	# Link Section
	xml.pbcorePart{
	  xml.pbcoreIdentifier(:source=>"")
	  xml.pbcoreTitle("ASSET LINK")
	  xml.pbcoreDescription
	  xml.pbcoreAssetType(:ref=>"", :annotation=>"")
	}
	# Derivatives (child element)
	xml.pbcorePart
      }

    end
    return builder.doc.root
  end

  def self.creator_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.pbcoreCreator("xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html"){
	  xml.creator(:affiliation=>"", :ref=>"", :annotation=>"")
	  xml.creatorRole(:source=>"", :ref=>"", :annotation=>"")
	}
    end
    return builder.doc.root
  end

  def self.contributor_template
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.pbcoreContributor("xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance",
        "xmlns"=>"http://www.pbcore.org/PBCore/PBCoreNamespace.html"){
	  xml.contributor
	  xml.contributorRole("speaker")
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
      when :master
        node = PbcoreXml.master_template
        nodeset = self.find_by_terms(:pbcoreDescriptionDocument, :pbcorePart)
      when :derivative
        node = PbcoreXml.derivative_template
        nodeset = self.find_by_terms(:pbcoreDescriptionDocument, :pbcorePart, :pbcorePart)
      when :derivative_l2
        node = PbcoreXml.derivative_template
        nodeset = self.find_by_terms(:pbcoreDescriptionDocument, :pbcorePart, :pbcorePart, :pbcorePart)
      when :creator
        node = PbcoreXml.creator_template
        nodeset = self.find_by_terms(:pbcoreDescriptionDocument, :pbcoreCreator)
      when :creator_master
        node = PbcoreXml.creator_template
        nodeset = self.find_by_terms(:pbcorePart, :pbcoreCreator)
      when :contributor
        node = PbcoreXml.part_template
        nodeset = self.find_by_terms(:pbcoreDescriptionDocument, :pbcorePart)
      when :assetlink
        node = PbcoreXml.assetlink_template
        nodeset = self.find_by_terms(:pbcoreDescriptionDocument, :pbcorePart)
      when :assetlink_master
        node = PbcoreXml.assetlink_template
        nodeset = self.find_by_terms(:pbcorePart, :pbcorePart)
      else
        ActiveFedora.logger.warn("#{type} is not a valid argument for PbcoreXml.insert_node")
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
      when :master
        remove_node = self.find_by_terms(:pbcoreDescriptionDocument, :pbcorePart, :pbcoreInstantiation)[index.to_i]
      when :derivative
        remove_node = self.find_by_terms(:pbcoreDescriptionDocument, :pbcorePart, :pbcoreDescriptionDocument, :pbcorePart)[index.to_i]
      when :speaker
        remove_node = self.find_by_terms(:pbcoreDescriptionDocument, :pbcorePart)[index.to_i]
      when :assetlink
        remove_node = self.find_by_terms(:pbcoreDescriptionDocument, :pbcorePart)[index.to_i]
      when :assetlink_master
        remove_node = self.find_by_terms(:pbcorePart, :pbcorePart)[index.to_i]
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
