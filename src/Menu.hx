import hxd.Event;
import h2d.Interactive;
import h2d.Scene;


class Menu extends Scene {

    var gameManager:GameManager;

    public function new(manager:GameManager) {
        super();
        gameManager =manager;
        this.scaleMode = ScaleMode.LetterBox(512,512);
        init();
    }

    function init(){

        initButtonPlay();
        initButtonRestart();

    }

    function initButtonPlay(){
        var font : h2d.Font = hxd.res.DefaultFont.get();
        var tf = new h2d.Text(font,this);
        tf.text = "Play";
        tf.scale(4);    
        tf.x = 0.5 * width;
        //tf.textAlign = Center;
        tf.y = this.height * 0.25;
        var inter = new Interactive(tf.textWidth,tf.textHeight,tf);
        inter.onClick= function (e:Event) {
            gameManager.play();    
        };
        inter.onOver= function (e:Event) {
            tf.alpha = 0.5;
        };
        inter.onOut = function (e:Event) {
            tf.alpha = 1;
        }
    }

    function initButtonRestart(){
        var font : h2d.Font = hxd.res.DefaultFont.get();
        var tf = new h2d.Text(font,this);
        tf.scale(4);
        tf.text = "Restart";
       // tf.textAlign = Center;
        tf.x = 0.5 * width;
        tf.y = this.height * 0.50;
        var inter = new Interactive(tf.textWidth,tf.textHeight,tf);
        inter.onClick= function (e:Event) {
            gameManager.restart();    
        };
        inter.onOver= function (e:Event) {
            tf.alpha = 0.5;
        };
        inter.onOut = function (e:Event) {
            tf.alpha = 1;
        }
    }

    function initFilter(){
		var g = new h2d.filter.Glow(0x48FF00, 50, 2);
		g.knockout = true;
		this.filter = new h2d.filter.Group([g, new h2d.filter.Blur(3), new h2d.filter.DropShadow(8, Math.PI / 4)]);
	}

}