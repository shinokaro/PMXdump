module PMXReader
  def load_pmx(filepath)
    pInfo = PMXInfo.new();
    begin
      miku = open(filepath, "rb")
    rescue #Filenotfound
      raise "ERROR: PMX file could not be found: #{filpath}"
    end
    header_info(miku)
    p :model
    model_info(miku)
    p :vertex
    vertex_info(miku)
    p :face
    face_info(miku, filepath)
    p :material
    material_info(miku)
    p :born
    born_info(miku)
    p :morph
    morph_info(miku)
    p :display
    display_frame_info(miku)
    p :rigid
    rigid_body_info(miku)
    p :joint
    joint_info(miku)
  end	
  def header_info(miku)
    self.header_str= miku.read(4)
    self.ver=        miku.read_float
    raise "Error: Only version 2.0 of the PMX file format is supported!" if self.ver != 2.0
    self.line_size=          miku.read_uint8
    self.unicode_type=       miku.read_bool
    self.extraUVCount=       miku.read_uint8
    self.vertexIndexSize=    miku.read_uint8
    self.textureIndexSize=   miku.read_uint8
    self.materialIndexSize=  miku.read_uint8
    self.boneIndexSize=      miku.read_uint8
    self.morphIndexSize=     miku.read_uint8
    self.rigidBodyIndexSize= miku.read_uint8
  end
  def model_info(miku)
    self.modelName=        miku.read_pmx_text(self.unicode_type)
    self.modelNameEnglish= miku.read_pmx_text(self.unicode_type)
    self.comment=          miku.read_pmx_text(self.unicode_type)
    self.commentEnglish=   miku.read_pmx_text(self.unicode_type)
  end
  def vertex_info(miku)
    self.vertex_continuing_datasets= miku.read_int
    self.vertex_continuing_datasets.times {
      vertex = PMXVertex.new
      vertex.pos.x=    miku.read_float
      vertex.pos.y=    miku.read_float
      vertex.pos.z=    miku.read_float
      vertex.normal.x= miku.read_float
      vertex.normal.y= miku.read_float
      vertex.normal.z= miku.read_float
      vertex.UV.x=     miku.read_float
      vertex.UV.y=     miku.read_float
      vertex.weight_transform_formula= miku.read_uint8
      case vertex.weight_transform_formula
      when WEIGHT_FORMULA_BDEF1
        vertex.boneIndex1= miku.read_pmx_index(self.boneIndexSize)
      when WEIGHT_FORMULA_BDEF2
        vertex.boneIndex1= miku.read_pmx_index(self.boneIndexSize)
        vertex.boneIndex2= miku.read_pmx_index(self.boneIndexSize)
        vertex.weight1=    miku.read_float
        vertex.weight2=    1.0 - vertex.weight1 #For BDEF2: weight of bone2=1.0-weight1
      when WEIGHT_FORMULA_BDEF4
        vertex.boneIndex1= miku.read_pmx_index(self.boneIndexSize)
        vertex.boneIndex2= miku.read_pmx_index(self.boneIndexSize)
        vertex.boneIndex3= miku.read_pmx_index(self.boneIndexSize)
        vertex.boneIndex4= miku.read_pmx_index(self.boneIndexSize)
        vertex.weight1=    miku.read_float
        vertex.weight2=    miku.read_float
        vertex.weight3=    miku.read_float
        vertex.weight4=    miku.read_float
      when WEIGHT_FORMULA_SDEF
        vertex.boneIndex1= miku.read_pmx_index(self.boneIndexSize)
        vertex.boneIndex2= miku.read_pmx_index(self.boneIndexSize)		
        vertex.weight1=    miku.read_float
      # vertex.weight2= 1.0 - vertex.weight1; //For BDEF2 and SDEF: weight of bone2=1.0-weight1
        vertex.C.x=  miku.read_float
        vertex.C.y=  miku.read_float
        vertex.C.z=  miku.read_float
        vertex.R0.x= miku.read_float
        vertex.R0.y= miku.read_float
        vertex.R0.z= miku.read_float
        vertex.R1.x= miku.read_float
        vertex.R1.y= miku.read_float
        vertex.R1.z= miku.read_float
      else
        raise "ERROR: bone structure (QDEF?) not supported yet"
      end
    
      vertex.edgeScale= miku.read_float
      self.vertices << vertex
    }
  end
  def face_info(miku, filepath="./")
    self.face_continuing_datasets= miku.read_int
    (self.face_continuing_datasets / 3).times {
        face = PMXFace.new
        face.points[0]= miku.read_pmx_index(self.vertexIndexSize)
        face.points[1]= miku.read_pmx_index(self.vertexIndexSize)
        face.points[2]= miku.read_pmx_index(self.vertexIndexSize)
        self.faces << face
    }
    self.texture_continuing_datasets= miku.read_int
    self.texturePaths= Array.new(self.texture_continuing_datasets + 11)
    self.texture_continuing_datasets.times { |i|
	    self.texturePaths[i]= File.join(File.dirname(filepath),	miku.read_pmx_text(self.unicode_type))
    }
	end
  def material_info(miku)
    self.material_continuing_datasets= miku.read_int
    self.material_continuing_datasets.times {
      material = PMXMaterial.new
      material.name=    miku.read_pmx_text(self.unicode_type)
      material.nameEng= miku.read_pmx_text(self.unicode_type)
      material.diffuse.x=  miku.read_float
      material.diffuse.y=  miku.read_float
      material.diffuse.z=  miku.read_float
      material.diffuse.w=  miku.read_float
      material.specular.r= miku.read_float
      material.specular.g= miku.read_float
      material.specular.b= miku.read_float
      material.shininess=  miku.read_float
      material.ambient.x=  miku.read_float
      material.ambient.y=  miku.read_float
      material.ambient.z=  miku.read_float
      
      bitflag = miku.read_bit(5)
      material.drawBothSides=       bitflag[0]
      material.drawGroundShadow=    bitflag[1]
      material.drawToSelfShadowMap= bitflag[2]
      material.drawSelfShadow=      bitflag[3]
      material.drawEdges=           bitflag[4]
      
      material.edgeColor.r=  miku.read_float
      material.edgeColor.g=  miku.read_float
      material.edgeColor.b=  miku.read_float
      material.edgeColor.a=  miku.read_float
      material.edgeSize=     miku.read_float
      material.textureIndex= miku.read_pmx_index(self.textureIndexSize)
      material.sphereIndex=  miku.read_pmx_index(self.textureIndexSize)
      material.sphereMode=   miku.read_uint8
      material.shareToon=    miku.read_uint8
        
      if material.shareToon == 1
        material.shareToonTexture= miku.read_uint8
      else
        material.toonTextureIndex= miku.read_pmx_index(self.textureIndexSize)
      end
        
      material.memo= miku.read_pmx_text(self.unicode_type)
      material.hasFaceNum= miku.read_int
      self.materials << material
    }
  end
  def born_info(miku)
    self.bone_continuing_datasets= miku.read_int
    self.bone_continuing_datasets.times {
      bone = PMXBone.new
      bone.name=    miku.read_pmx_text(self.unicode_type)
      bone.nameEng= miku.read_pmx_text(self.unicode_type)
      bone.position.x= miku.read_float
      bone.position.y= miku.read_float
      bone.position.z= miku.read_float
      p bone.parentBoneIndex= miku.read_pmx_index(self.boneIndexSize)
      if bone.parentBoneIndex != -1
        bone.parent= self.bones[bone.parentBoneIndex]
      else
        bone.parent= nil
      end
      p bone.transformationLevel= miku.read_int
      p bitflag = miku.read_bit(6)
      bone.connectionDisplayMethod= bitflag[0]
      bone.rotationPossible=        bitflag[1]
      bone.movementPossible=        bitflag[2]
      bone.show=                    bitflag[3]
      bone.controlPossible=         bitflag[4]
      bone.IK=                      bitflag[5]
      
      p bitflag2 = miku.read_bit(6)
      bone.giveRotation=            bitflag2[0]
      bone.giveTranslation=         bitflag2[1]
      bone.axisFixed=               bitflag2[2]
      bone.localAxis=               bitflag2[3]
      bone.transformAfterPhysics=   bitflag2[4]
      bone.externalParentTransform= bitflag2[5]
      
      if bone.connectionDisplayMethod
        # true: Display with Bone
        p bone.connectionBoneIndex= miku.read_pmx_index(self.boneIndexSize)
      else
        # false: Display with Coordinate Offset
        p bone.coordinateOffset.x= miku.read_float
        p bone.coordinateOffset.y= miku.read_float
        p bone.coordinateOffset.z= miku.read_float
      end
      if bone.giveRotation || bone.giveTranslation
        p bone.givenParentBoneIndex= miku.read_pmx_index(self.boneIndexSize)
        p bone.giveRate= miku.read_float
      end
      if bone.axisFixed
        p bone.axisDirectionVector.x= miku.read_float
        p bone.axisDirectionVector.y= miku.read_float
        p bone.axisDirectionVector.z= miku.read_float
      end
      if bone.localAxis
        p bone.XAxisDirectionVector.x= miku.read_float
        p bone.XAxisDirectionVector.y= miku.read_float
        p bone.XAxisDirectionVector.z= miku.read_float
        p bone.ZAxisDirectionVector.x= miku.read_float
        p bone.ZAxisDirectionVector.y= miku.read_float
        p bone.ZAxisDirectionVector.z= miku.read_float
      end
      if bone.externalParentTransform
        p bone.keyValue= miku.read_int
      end
      if bone.IK
        p bone.IKTargetBoneIndex= miku.read_pmx_index(self.boneIndexSize)
				p bone.IKLoopCount=       miku.read_uint
				p bone.IKLoopAngleLimit=  miku.read_float
				p bone.IKLinkNum=         miku.read_uint
				exit
				bone.IKLinkNum.times {
					link = PMXIKLink.new
					link.linkBoneIndex = miku.read_pmx_index(self.boneIndexSize)
					link.angleLimit= miku.read_bool
					if link.angleLimit
						link.lowerLimit.x= miku.read_float
						link.lowerLimit.y= miku.read_float
						link.lowerLimit.z= miku.read_float
						link.upperLimit.x= miku.read_float
						link.upperLimit.y= miku.read_float
						link.upperLimit.z= miku.read_float
					end
					bone.IKLinks << link
				}
			end
						
      bone.Local[3][0]= bone.position.x
      bone.Local[3][1]= bone.position.y
      bone.Local[3][2]= bone.position.z
      self.bones << bone
    }
  end
	def morph_info(miku)
		self.morph_continuing_datasets = miku.read_int
		self.morph_continuing_datasets.times {
			morph = PMXMorph.new
			morph.name=    miku.read_pmx_text(self.unicode_type)
			morph.nameEng= miku.read_pmx_text(self.unicode_type)
			morph.controlPanel=   miku.read_uint8
			morph.type=           miku.read_uint8
			morph.morphOffsetNum= miku.read_int
			morph.morphOffsetNum.times {
				data = PMXMorphData.new
				case morph.type
				when MORPH_TYPE_VERTEX
					vertexMorph = PMXVertexMorph.new
					vertexMorph.vertexIndex= miku.read_pmx_index(self.vertexIndexSize)
					vertexMorph.coordinateOffset.x= miku.read_float
					vertexMorph.coordinateOffset.y= miku.read_float
					vertexMorph.coordinateOffset.z= miku.read_float
					data = vertexMorph
				when MORPH_TYPE_UV, MORPH_TYPE_EXTRA_UV1, MORPH_TYPE_EXTRA_UV2, MORPH_TYPE_EXTRA_UV3, MORPH_TYPE_EXTRA_UV4
					uVMorph = PMXUVMorph.new
					uVMorph.vertexIndex= miku.read_pmx_index(self.vertexIndexSize)
					uVMorph.UVOffsetAmount.x= miku.read_float
					uVMorph.UVOffsetAmount.y= miku.read_float
					uVMorph.UVOffsetAmount.z= miku.read_float
					uVMorph.UVOffsetAmount.w= miku.read_float
					data = uVMorph
				when MORPH_TYPE_BONE
					boneMorph = PMXBoneMorph.new
					boneMorph.boneIndex= miku.read_pmx_index(self.boneIndexSize)
					boneMorph.inertia.x= miku.read_float
					boneMorph.inertia.y= miku.read_float
					boneMorph.inertia.z= miku.read_float
					boneMorph.rotationAmount.x= miku.read_float
					boneMorph.rotationAmount.y= miku.read_float
					boneMorph.rotationAmount.z= miku.read_float
					boneMorph.rotationAmount.w= miku.read_float
					data = boneMorph
				when MORPH_TYPE_MATERIAL
					materialMorph = PMXMaterialMorph.new
					materialMorph.materialIndex= miku.read_pmx_index(self.materialIndexSize)
					materialMorph.offsetCalculationFormula= miku.read_uint8
					materialMorph.diffuse.r=  miku.read_float
					materialMorph.diffuse.g=  miku.read_float
					materialMorph.diffuse.b=  miku.read_float
					materialMorph.diffuse.a=  miku.read_float
					materialMorph.specular.r= miku.read_float
					materialMorph.specular.g= miku.read_float
					materialMorph.specular.b= miku.read_float
					materialMorph.shininess=  miku.read_float
					materialMorph.ambient.r=  miku.read_float
					materialMorph.ambient.g=  miku.read_float
					materialMorph.ambient.b=  miku.read_float
					materialMorph.edgeColor.r= miku.read_float
					materialMorph.edgeColor.g= miku.read_float
					materialMorph.edgeColor.b= miku.read_float
					materialMorph.edgeColor.a= miku.read_float
					materialMorph.edgeSize=    miku.read_float
					materialMorph.textureCoefficient.r= miku.read_float
					materialMorph.textureCoefficient.g= miku.read_float
					materialMorph.textureCoefficient.b= miku.read_float
					materialMorph.textureCoefficient.a= miku.read_float
					materialMorph.sphereTextureCoefficient.r= miku.read_float
					materialMorph.sphereTextureCoefficient.g= miku.read_float
					materialMorph.sphereTextureCoefficient.b= miku.read_float
					materialMorph.sphereTextureCoefficient.a= miku.read_float
					materialMorph.toonTextureCoefficient.r= miku.read_float
					materialMorph.toonTextureCoefficient.g= miku.read_float
					materialMorph.toonTextureCoefficient.b= miku.read_float
					materialMorph.toonTextureCoefficient.a= miku.read_float
					data = materialMorph
				when MORPH_TYPE_GROUP
					groupMorph = PMXGroupMorph.new()
					groupMorph.morphIndex= miku.read_pmx_index(self.morphIndexSize)
					groupMorph.morphRate=  miku.read_float
				else #	default
					raise "Unknown morph type or faulty data/reading"
				end
				
				morph.offsetData << data
			}
	    self.morphs << morph
    } 
  end
	def display_frame_info(miku)
    self.display_frame_continuing_datasets= miku.read_int
		self.display_frame_continuing_datasets.times {
			df = PMXDisplayFrame.new
			df.name=    miku.read_pmx_text(self.unicode_type)
			df.nameEng= milu.read_pmx_text(self.unicode_type)
			df.specialFrameFlag=    miku.read_bool # 0:Normal Frame 1:Special Frame
			df.elementsWithinFrame= miku.read_int  # Number of continuing elements
			df.elementsWithinFrame.times {
				element = PMXDisplayFrameElement.new
				element.target= miku.read_bool
				if element.target # Bone
					element.index= miku.read_pmx_index(self.boneIndexSize)
				else # Morph
					element.index= miku.read_pmx_index(self.morphIndexSize)
				end
				df.elements << element
			}
			self.displayFrames << df
		}
  end
	def rigid_body_info(miku)
    self.rigid_body_continuing_datasets= miku.read_int
    self.rigid_body_continuing_datasets.times {
      rb = PMXRigidBody.new
      rb.name=    read_pmx_text(self.unicode_type)
      rb.nameEng= read_pmx_text(self.unicode_type)
      rb.relatedBoneIndex= miku.read_int(self.boneIndexSize) # Set to -1 when irrelevant/unrelated
      rb.group= miku.read_uint8
      rb.noCollisionGroupFlag= miku.read_uint16
      rb.shape= miku.read_uint8 # 0:Circle 1:Square 2:Capsule
      rb.size.x= miku.read_float
      rb.size.y= miku.read_float
      rb.size.z= miku.read_float
      rb.position.x= miku.read_float
      rb.position.y= miku.read_float
      rb.position.z= miku.read_float
      rb.rotation.x= miku.read_float
      rb.rotation.y= miku.read_float
      rb.rotation.z= miku.read_float
      rb.mass=       miku.read_float
      rb.movementDecay= miku.read_float
      rb.rotationDecay= miku.read_float
      rb.elasticity=    miku.read_float
      rb.friction=      miku.read_float
      rb.physicsOperation= miku.read_uint8
      self.rigidBodies << rb
      # VARIABLES I ADDED BELOW THIS POINT; glm::mat4 Init; //The initial transformation matrix; glm::mat4 Offset; //The current offset matrix
    }
  end
	def joint_info(miku)
    self.joint_continuing_datasets= miku.read_int
    self.joint_continuing_datasets.times {
      joint = PMXJoint.new
      joint.name=    miku.read_pmx_text(UTF8, self.text_encode)
      joint.nameEng= miku.read_pmx_text(UTF8, self.text_encode)
      joint.type= miku.read_bool # 0:Spring 6DOF; in PMX 2.0 always set to 0 (included to give room for expansion)
      if joint.type == 0
        joint.relatedRigidBodyIndexA= miku.read_pmx_index(self.rigidBodyIndexSize)# VARIABLES I ADDED BELOW THIS POINT; glm::mat4 Local; //joint matrix, local to relatedRigidBodyA
        joint.relatedRigidBodyIndexB= miku.read_pmx_index(self.rigidBodyIndexSize)
        joint.position.x= miku.read_float
        joint.position.y= miku.read_float
        joint.position.z= miku.read_float
        joint.rotation.x= miku.read_float
        joint.rotation.y= miku.read_float
        joint.rotation.z= miku.read_float
        joint.movementLowerLimit.x= miku.read_float
        joint.movementLowerLimit.y= miku.read_float
        joint.movementLowerLimit.z= miku.read_float
        joint.movementUpperLimit.x= miku.read_float
        joint.movementUpperLimit.y= miku.read_float
        joint.movementUpperLimit.z= miku.read_float
        joint.rotationLowerLimit.x= miku.read_float
        joint.rotationLowerLimit.y= miku.read_float
        joint.rotationLowerLimit.z= miku.read_float
        joint.rotationUpperLimit.x= miku.read_float
        joint.rotationUpperLimit.y= miku.read_float
        joint.rotationUpperLimit.z= miku.read_float
        joint.springMovementConstant.x= miku.read_float
        joint.springMovementConstant.y= miku.read_float
        joint.springMovementConstant.z= miku.read_float
        joint.springRotationConstant.x= miku.read_float
        joint.springRotationConstant.y= miku.read_float
        joint.springRotationConstant.z= miku.read_float
      else
        raise "Unsupported PMX format version or file reading error"
      end
      self.joints << joint
    }
  end
end