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
        Main.iteration[0] = iteration0.value;
        Main.iteration[1] = iteration1.value;
        Main.param[0] = param0.value;
        Main.param[1] = param1.value;
        Main.start[0] = start.value;
        Main.balance[0] = balance.value;
        
        Main.colpos[0] = r1.value;
        Main.colpos[1] = g1.value;
        Main.colpos[2] = b1.value;
        
        Main.colmid[0] = r2.value;
        Main.colmid[1] = g2.value;
        Main.colmid[2] = b2.value;
        
        Main.colneg[0] = r3.value;
        Main.colneg[1] = g3.value;
        Main.colneg[2] = b3.value;
    }
}