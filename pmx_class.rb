WEIGHT_FORMULA_BDEF1 = 0
WEIGHT_FORMULA_BDEF2 = 1
WEIGHT_FORMULA_BDEF4 = 2
WEIGHT_FORMULA_SDEF = 3

MORPH_TYPE_GROUP = 0
MORPH_TYPE_VERTEX = 1
MORPH_TYPE_BONE = 2
MORPH_TYPE_UV = 3
MORPH_TYPE_EXTRA_UV1 = 4
MORPH_TYPE_EXTRA_UV2 = 5
MORPH_TYPE_EXTRA_UV3 = 6
MORPH_TYPE_EXTRA_UV4 = 7
MORPH_TYPE_MATERIAL = 8

RIGID_SHAPE_SPHERE = 0
RIGID_SHAPE_CUBE = 1
RIGID_SHAPE_CAPSULE = 2

VERTEX_DEBUG   = false
MATERIAL_DEBUG = true

PMX_ENCODE_UTF16 = 0
PMX_ENCODE_UTF8 = 1

require "forwardable"
module GLM; end
GLM::VEC2 = Struct.new(:x, :y)
class GLM::VEC3 < Struct.new(:x, :y, :z)
  extend Forwardable
  def_delegator :self, :x,  :r
  def_delegator :self, :x=, :r=
  def_delegator :self, :y,  :g
  def_delegator :self, :y=, :g=
  def_delegator :self, :z,  :b
  def_delegator :self, :z=, :b=  
end
class GLM::VEC4 < Struct.new(:x, :y, :z, :w)
  extend Forwardable
  def_delegator :self, :x,  :r
  def_delegator :self, :x=, :r=
  def_delegator :self, :y,  :g
  def_delegator :self, :y=, :g=
  def_delegator :self, :z,  :b
  def_delegator :self, :z=, :b=
  def_delegator :self, :w,  :a
  def_delegator :self, :w=, :a=
end
class GLM::MAT4
  def initialize
    @m = [[0.0, 0.0, 0.0, 0.0],
          [0.0, 0.0, 0.0, 0.0],
          [0.0, 0.0, 0.0, 0.0],
          [0.0, 0.0, 0.0, 0.0]]
  end
  def [](pos)
    @m.at(pos)
  end
end
#module ClosedMMDFormat
  class PMXVertex < Struct.new(:pos, :normal, :UV, :weight_transform_formula,
                          :boneIndex1, :boneIndex2, :boneIndex3, :boneIndex4,
                          :weight1, :weight2, :weight3, :weight4,
                          :C, :R0, :R1, :edgeScale)
    def initialize
      super()
      self.pos= GLM::VEC3.new
      self.normal= GLM::VEC3.new
      self.UV= GLM::VEC2.new
      self.C= GLM::VEC3.new
      self.R0= GLM::VEC3.new
      self.R1= GLM::VEC3.new
    end
  end
  class PMXFace < Struct.new(:points)
    def initialize
      super()
      self.points= Array.new(3)
    end
  end
  class PMXMaterial < Struct.new(:name, :nameEng,
                          :diffuse, :specular, :shininess, :ambient,
                          :drawBothSides, :drawGroundShadow, :drawToSelfShadowMap, :drawSelfShadow, :drawEdges,
                          :edgeColor, :edgeSize, :textureIndex, :sphereIndex, :sphereMode, :shareToon,
                          :toonTextureIndex, :shareToonTexture, :memo, :hasFaceNum)
    def initialize
      super()
      self.diffuse=   GLM::VEC4.new
      self.specular=  GLM::VEC3.new
      self.ambient=   GLM::VEC3.new
      self.edgeColor= GLM::VEC4.new
    end
  end
  class PMXIKLink < Struct.new(:linkBoneIndex, :angleLimit, :lowerLimit, :upperLimit)
    def initialize
      super()
      self.lowerLimit= GLM::VEC3.new
      self.upperLimit= GLM::VEC3.new
    end
  end
  class PMXBone < Struct.new(:name, :nameEng, :position, :parentBoneIndex, :transformationLevel,
                        :connectionDisplayMethod, :rotationPossible, :movementPossible, :show, :controlPossible,
                        :IK, :giveRotation, :giveTranslation, :axisFixed, :localAxis,
                        :transformAfterPhysics, :externalParentTransform, :coordinateOffset, 
                        :connectionBoneIndex, :givenParentBoneIndex, :giveRate,
                        :axisDirectionVector, :XAxisDirectionVector, :ZAxisDirectionVector, :keyValue,
                        :IKTargetBoneIndex, :IKLoopCount, :IKLoopAngleLimit, :IKLinkNum, :IKLinks, :Local, :parent)
    def initialize
      super()
      self.position= GLM::VEC3.new
      self.coordinateOffset= GLM::VEC3.new
      self.axisDirectionVector=  GLM::VEC3.new
      self.XAxisDirectionVector= GLM::VEC3.new
      self.ZAxisDirectionVector= GLM::VEC3.new
      self.IKLinks = []
      self.Local= GLM::MAT4.new
    end
    def calculateGlobalMatrix
      if parent
        parent.calculateGlobalMatrix * Local
      else
        Local
      end
    end
  end
  class PMXMorphData < BasicObject; end
  class PMXVertexMorph < Struct.new(:vertexIndex, :coordinateOffset)
    def initialize
      super()
      self.coordinateOffset= GLM::VEC3.new
    end
  end
  class PMXUVMorph < Struct.new(:vertexIndex, :UVOffsetAmount)
    def initialize
      super()
      self.UVOffsetAmount= GLM::VEC4.new
    end
  end
  class PMXBoneMorph < Struct.new(:boneIndex, :inertia, :rotationAmount)
    def initialize
      super()
      self.inertia= GLM::VEC3.new
      self.rotationAmount= GLM::VEC4.new
    end
  end
  class PMXMaterialMorph < Struct.new(:materialIndex, :offsetCalculationFormula,
                                :diffuse, :specular, :shininess, :ambient, :edgeColor, :edgeSize,
                                :textureCoefficient, :sphereTextureCoefficient, :toonTextureCoefficient)
    def initialize
      super()
      self.diffuse=   GLM::VEC4.new
      self.specular=  GLM::VEC3.new
      self.ambient=   GLM::VEC3.new
      self.edgeColor= GLM::VEC4.new
      self.textureCoefficient= GLM::VEC4.new
      self.sphereTextureCoefficient= GLM::VEC4.new
      self.toonTextureCoefficient= GLM::VEC4.new
    end
  end
  PMXGroupMorph = Struct.new(:morphIndex, :morphRate)
  class PMXMorph < Struct.new(:name, :nameEng, :controlPanel, :type, :morphOffsetNum, :offsetData)
    def initialize
      super()
      self.offsetData= []
    end
  end
  PMXDisplayFrameElement = Struct.new(:target, :index)
  class PMXDisplayFrame < Struct.new(:name, :nameEng, :specialFrameFlag, :elementsWithinFrame, :elements)
    def initialize
      super()
      self.elements= []
    end
  end
  class PMXRigidBody < Struct.new(:name, :nameEng, :relatedBoneIndex, :group, :noCollisionGroupFlag,
                            :shape, :size, :position, :rotation, :mass, :movementDecay, :rotationDecay,
                            :elasticity, :friction, :physicsOperation, :Init, :Offset)
    def initialize
      super()
      self.size=     GLM::VEC3.new
      self.position= GLM::VEC3.new
      self.rotation= GLM::VEC3.new
      self.Init=     GLM::MAT4.new
      self.Offset=   GLM::MAT4.new
    end
  end
  class PMXJoint < Struct.new(:name, :nameEng, :type, :relatedRigidBodyIndexA, :relatedRigidBodyIndexB,
                        :position, :rotation, :movementLowerLimit, :movementUpperLimit, :rotationLowerLimit, :rotationUpperLimit,
                        :springMovementConstant, :springRotationConstant, :Local)
    def initialize
      super()
      self.position = GLM::VEC3.new
      self.rotation = GLM::VEC3.new
      self.movementLowerLimit = GLM::VEC3.new
      self.movementUpperLimit = GLM::VEC3.new
      self.rotationLowerLimit = GLM::VEC3.new
      self.rotationUpperLimit = GLM::VEC3.new
      self.springMovementConstant = GLM::VEC3.new
      self.springRotationConstant = GLM::VEC3.new
      self.Local = GLM::MAT4.new
    end
  end
  class PMXInfo < Struct.new(:header_str, :ver,
                        :line_size, :unicode_type, :extraUVCount,
                        :vertexIndexSize, :textureIndexSize, :materialIndexSize,
                        :boneIndexSize, :morphIndexSize, :rigidBodyIndexSize,
                        :modelName, :modelNameEnglish, :comment, :commentEnglish,
                        :vertex_continuing_datasets, :vertices,
                        :face_continuing_datasets, :faces,
                        :texture_continuing_datasets, :texturePaths,
                        :material_continuing_datasets, :materials,
                        :bone_continuing_datasets, :bones,
                        :morph_continuing_datasets, :morphs,
                        :display_frame_continuing_datasets, :displayFrames,
                        :rigid_body_continuing_datasets, :rigidBodies,
                        :joint_continuing_datasets, :joints)
    include PMXReader
    def initialize
      super()
      self.vertices = []
      self.faces = []
      self.texturePaths = []
      self.materials = []
      self.bones = []
      self.morphs =[]
      self.displayFrames = []
      self.rigidBodies = []
      self.joints= []
    end
  end
# end