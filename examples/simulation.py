import ISSofaPython as Sofa

class FreeMotionTaskSimulation(object):
    """
    FreeMotionTaskSimulation wraps the FreeMotionTaskAnimationLoop and
    GenericConstraintSolver components in a single class
    """
    def __init__(self,node):
        self.node = node
        self.camera = self.node.createObject("InteractiveCamera", name="MainCamera", position="0 0 50.041", lookAt="0 0 0",
                                             fieldOfView=9.5, zNear=0, zFar=250, zoomSpeed=1000, pivot=0)
        self.animation_loop = self.node.createObject("FreeMotionTaskAnimationLoop",name="animationLoop")
        self.constraint_solver = self.node.createObject("GenericConstraintSolver",name="constraintSolver",
                                                                                  reverseAccumulateOrder="1" )
        setattr(self,"constraint_tolerance",self.constraint_solver.tolerance)
        setattr(self,"constraint_max_iterations",self.constraint_solver.maxIterations)
        setattr(self,"dt",self.node.findData("dt"))
        setattr(self,"gravity",self.node.findData("gravity"))
        self.threadsCount = self.animation_loop.threadsCount


class FreeMotionSimulation(object):
    """
    FreeMotionSimulation wraps the FreeMotionAnimationLoop and
    GenericConstraintSolver components in a single class
    """
    def __init__(self,node):
        self.node = node
        self.camera = self.node.createObject("InteractiveCamera", name="MainCamera", position="0 0 50.041", lookAt="0 0 0",
                                             fieldOfView=9.5, zNear=0, zFar=250, zoomSpeed=1000, pivot=0)
        self.freemotion = self.node.createObject("FreeMotionAnimationLoop",name="freeMotion")
        self.animation_loop = self.freemotion
        self.freemotion.solveVelocityConstraintFirst.value = True
        self.constraint_solver = self.node.createObject("GenericConstraintSolver",name="constraintSolver",
                                                                                  reverseAccumulateOrder="1" )
        setattr(self,"constraint_tolerance",self.constraint_solver.tolerance)
        setattr(self,"constraint_max_iterations",self.constraint_solver.maxIterations)
        setattr(self,"dt",self.node.findData("dt"))
        setattr(self,"gravity",self.node.findData("gravity"))
        setattr(self,"post_stabilize",self.freemotion.postStabilize)
        
        
class CollisionPipeline(object):
    """
    CollisionPipeline object wraps the components responsible for the definition of the
    collision detection and response. MT can be used to disable multithreaded components.
    """
    def __init__(self, node, MT = True, LMD = False):
        self.node = node
        if MT:
            self.pipeline = node.createObject("DefaultPipelineMT", name="Pipeline", useComputeResponseMT=True)
            self.detection = node.createObject("FilteredBruteForceDetectionMT", name="Detection")
        else:
            self.pipeline = node.createObject("DefaultPipeline", name="Pipeline")
            self.detection = node.createObject("FilteredBruteForceDetection", name="Detection")
        self.contact_manager = node.createObject("DefaultContactManager",
                                                  name="ContactManager",
                                                  response="FrictionContact")
        if LMD:
            self.intersection = node.createObject("LocalMinDistance",
                                                  name="Intersection",
                                                  alarmDistance="0.5",
                                                  contactDistance="0")
        else:
            self.intersection = node.createObject("NewProximityIntersection",
                                                  name="Intersection",
                                                  alarmDistance="0.5",
                                                  contactDistance="0")

    def set_alarm_distance(self, alarm_distance):
        self.intersection.alarmDistance.value = alarm_distance

    def get_alarm_distance(self):
        return self.intersection.alarmDistance.value

    def set_contact_distance(self, contact_distance):
        self.intersection.contactDistance.value = contact_distance

    def get_contact_distance(self):
        return self.intersection.contactDistance.value
