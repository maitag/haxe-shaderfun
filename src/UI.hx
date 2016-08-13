package;

import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;

@:build(haxe.ui.macros.ComponentMacros.build("assets/ui/ui.xml"))
class UI extends Component {
    public function new() {
        super();
        
        iteration0.onChange = updateView;
        iteration1.onChange = updateView;
        param0.onChange = updateView;
        param1.onChange = updateView;
        start.onChange = updateView;
        balance.onChange = updateView;
        r1.onChange = updateView;
        g1.onChange = updateView;
        b1.onChange = updateView;
        r2.onChange = updateView;
        g2.onChange = updateView;
        b2.onChange = updateView;
        r3.onChange = updateView;
        g3.onChange = updateView;
        b3.onChange = updateView;
        
        updateView();
    }
    
    private function updateView(e = null) {
        // need to parseFloat here as Main.iteration[0] is a Dynamic and Variant (.value) doesnt know to use Float
        // best change would be to make Main.iteration an Array<Float> but i tried and it broke other things relating
        // to the fractals, so left it as is
        Main.iteration[0] = Std.parseFloat(iteration0.value);
        Main.iteration[1] = Std.parseFloat(iteration1.value);
        Main.param[0] = Std.parseFloat(param0.value);
        Main.param[1] = Std.parseFloat(param1.value);
        Main.start[0] = Std.parseFloat(start.value);
        Main.balance[0] = Std.parseFloat(balance.value);
        
        Main.colpos[0] = Std.parseFloat(r1.value);
        Main.colpos[1] = Std.parseFloat(g1.value);
        Main.colpos[2] = Std.parseFloat(b1.value);
        
        Main.colmid[0] = Std.parseFloat(r2.value);
        Main.colmid[1] = Std.parseFloat(g2.value);
        Main.colmid[2] = Std.parseFloat(b2.value);
        
        Main.colneg[0] = Std.parseFloat(r3.value);
        Main.colneg[1] = Std.parseFloat(g3.value);
        Main.colneg[2] = Std.parseFloat(b3.value);
    }
}