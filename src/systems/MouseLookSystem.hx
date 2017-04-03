package systems;

import edge.ISystem;
import components.MouseLook;
import mammoth.components.Transform;
import mammoth.Mammoth;

class MouseLookSystem implements ISystem {
    var directionAxis:Vec3 = new Vec3(0, 0, 1);
    var qDirection:Quat = Quat.identity(new Quat());

    var elevationAxis:Vec3 = new Vec3(1, 0, 0);
    var qElevation:Quat = Quat.identity(new Quat());

    public function before():Void {
        if(!Mammoth.input.pointerLocked) {
            Mammoth.input.lockPointer();
        }
    }

    public function update(transform:Transform, mouseLook:MouseLook) {
        if(!Mammoth.input.pointerLocked) return;

        // smooth the mouse movement so things aren't quite so janky
        mouseLook.smoothX = GLM.lerp(mouseLook.smoothX, Mammoth.input.mouseDeltaX, 1.0 / mouseLook.smoothing);
        mouseLook.smoothY = GLM.lerp(mouseLook.smoothY, Mammoth.input.mouseDeltaY, 1.0 / mouseLook.smoothing);

        mouseLook.direction -= mouseLook.smoothX * mouseLook.sensitivity * Mammoth.timing.dt;
        mouseLook.elevation -= mouseLook.smoothY * mouseLook.sensitivity * Mammoth.timing.dt;        

        while(mouseLook.direction > 2 * Math.PI)
            mouseLook.direction -= 2 * Math.PI;
        while(mouseLook.direction < 0)
            mouseLook.direction += 2 * Math.PI;

        // clamp looking up or down to straight down or straight up,
        // don't go past that. Things get weird there.
        if(mouseLook.elevation < 0)
            mouseLook.elevation = 0;
        if(mouseLook.elevation > Math.PI)
            mouseLook.elevation = Math.PI;

        Quat.axisAngle(directionAxis, mouseLook.direction, qDirection);
        Quat.axisAngle(elevationAxis, mouseLook.elevation, qElevation);

        // the order of this is important!
        transform.rotation.identity();
        transform.rotation.multiplyQuats(qDirection, transform.rotation);
        transform.rotation.multiplyQuats(qElevation, transform.rotation);
    }
}