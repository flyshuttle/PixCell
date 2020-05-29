void drawKinectSkeleton()
{
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();
  
  //individual JOINTS
  for (int i = 0; i < skeletonArray.size(); i++) 
  {
    KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
    if (skeleton.isTracked()) {
      KJoint[] joints = skeleton.getJoints();
      color col  = skeleton.getIndexColor();
      fill(col);
      stroke(col);
      drawBody(joints);
    }
  }  
}


void drawBody(KJoint[] joints) 
{
  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);
}


void drawBone(KJoint[] joints, int jointType1, int jointType2) 
{
  pushMatrix();
  translate(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
  line(joints[jointType1].getX(), joints[jointType1].getY(), joints[jointType1].getZ(), joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}


void drawJoint(KJoint[] joints, int jointType) 
{
  //κρατα τις συντεταγμενες ωστε να γεννηθουν κυτταρα
  if (jointType == KinectPV2.JointType_ThumbLeft)
  {
    leftHandX = joints[jointType].getX();
    leftHandY = joints[jointType].getY();
  }
  else
  {
    rightHandX = joints[jointType].getX();
    rightHandY = joints[jointType].getY();
  }
  fill(255,15,196,90);
  noStroke();
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 50, 50);
  popMatrix();
}
