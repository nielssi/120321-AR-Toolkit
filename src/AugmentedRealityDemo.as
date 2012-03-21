package {
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.ByteArray;
	
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.detector.FLARMultiMarkerDetector;
	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;
	import org.libspark.flartoolkit.pv3d.FLARBaseNode;
	import org.libspark.flartoolkit.pv3d.FLARCamera3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.shadematerials.FlatShadeMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.primitives.*;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
	[SWF(width="640", height="480", frameRate="24", backgroundColor="#000000")]

	public class AugmentedRealityDemo extends Sprite
	{
		[Embed(source="meinMuster.pat", mimeType="application/octet-stream")]
		private var pattern: Class;
		
		[Embed(source="camera_para.dat", mimeType="application/octet-stream")]
		private var params: Class;
		
		private var fparams: FLARParam;
		private var mpattern: FLARCode;
		private var vid: Video;
		private var cam: Camera;
		private var bmd: BitmapData;
		private var raster: FLARRgbRaster_BitmapData;
		private var detector: FLARSingleMarkerDetector;
		private var scene: Scene3D;
		private var camera: FLARCamera3D;
		private var container: FLARBaseNode;
		private var vp: Viewport3D;
		private var bre: BasicRenderEngine;
		private var trans: FLARTransMatResult;
		private var model: DAE;
		private var cow1: DAE;
		private var cube: Cube;
		private var cube2: Cube;
		private var cube3: Cube;
		
		public function AugmentedRealityDemo():void
		{
			setupFLAR();
			setupCamera();
			setupBitmap();
			setupPV3D();
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		private function setupFLAR():void
		{
			fparams = new FLARParam();
			fparams.loadARParam(new params() as ByteArray);
			mpattern = new FLARCode(16, 16);
			mpattern.loadARPatt(new pattern());
		}
		
		private function setupCamera():void
		{
			vid = new Video(640, 480);
			cam = Camera.getCamera();
			cam.setMode(640, 480, 60);
			vid.attachCamera(cam);
			addChild(vid);
		}
		
		private function setupBitmap():void
		{
			bmd = new BitmapData(640, 480);
			bmd.draw(vid);
			raster = new FLARRgbRaster_BitmapData(bmd);
			detector = new FLARSingleMarkerDetector(fparams, mpattern, 80);
		}
		
		private function setupPV3D():void
		{
			scene = new Scene3D();
			camera= new FLARCamera3D(fparams);
			container = new FLARBaseNode();
			bre = new BasicRenderEngine();
			trans = new FLARTransMatResult();
			vp = new Viewport3D();
			scene.addChild(container);
			
			 // -- Hier Würfel
			var matlist: MaterialsList = new MaterialsList();
			matlist.addMaterial(new FlatShadeMaterial(new PointLight3D(), 0xFFFF00, 0xFF0FFF), "all");
			cube = new Cube(matlist, 50, 50, 50, 8, 8, 8, 0, 0); 
			cube.x = 0;
			cube.y = 0;
			cube.z = 0;
			container.addChild(cube);
			addChild(vp);
		}
		
		private function loop(e:Event):void
		{
			bmd.draw(vid);
			try
			{
				if(detector.detectMarkerLite(raster, 80) && detector.getConfidence() > 0.5)
				{
					detector.getTransformMatrix(trans);
					container.setTransformMatrix(trans);
					bre.renderScene(scene, camera, vp);
				}
			}
			catch(e:Error){}
		}
	}
}
