package;

import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import haxe.ui.core.Component;
import haxe.ui.core.MouseEvent;
import haxe.ui.core.UIEvent;

@:build(haxe.ui.macros.ComponentMacros.build("assets/ui/ui.xml"))
class UI extends Component {
	
    public function new() {
        super();
        
        registerEvent(MouseEvent.MOUSE_DOWN, function(e:MouseEvent) { Main.uiIsdragging = true; });
        registerEvent(MouseEvent.MOUSE_UP  , function(e:MouseEvent) { Main.dragmode = Main.uiIsdragging = false; });
		
		for (i in [iteration0, iteration1, param0, param1, start, balance, r1, g1, b1, r2, g2, b2, r3, g3, b3])
			i.registerEvent(MouseEvent.MOUSE_UP , updateChanges);		
		
		iteration0.userData = [Main.iteration,0];
		iteration1.userData = [Main.iteration,1];
		param0.userData = [Main.param,0];
		param1.userData = [Main.param,1];
		start.userData  = [Main.start,0];
		balance.userData= [Main.balance,0];
		r1.userData = [Main.colpos,0];
		g1.userData = [Main.colpos,1];
		b1.userData = [Main.colpos,2];
		r2.userData = [Main.colmid,0];
		g2.userData = [Main.colmid,1];
		b2.userData = [Main.colmid,2];
		r3.userData = [Main.colneg,0];
		g3.userData = [Main.colneg,1];
		b3.userData = [Main.colneg,2];
		
		// TODO
		changeFormula.onClick = function(e:UIEvent) { Main.updateFormula(formula.text); };
		
        iteration0.onChange = updateValue;
        iteration1.onChange = updateValue;
        param0.onChange = updateValue;
        param1.onChange = updateValue;
        start.onChange  = updateValue;
        balance.onChange= updateValue;
        r1.onChange = updateValue;
        g1.onChange = updateValue;
        b1.onChange = updateValue;
        r2.onChange = updateValue;
        g2.onChange = updateValue;
        b2.onChange = updateValue;
        r3.onChange = updateValue;
        g3.onChange = updateValue;
        b3.onChange = updateValue;
		
		randomParam.onClick = updateChanges;
		randomColor.onClick = updateChanges;
    }
    
    private function updateChanges(e:UIEvent) {
		if (Main.changed) {
			Main.changed = false;
			Main.updateUrlParams();
		}
	}
	
    private function updateValue(e:UIEvent) {
		e.target.userData[0][e.target.userData[1]] = e.target.value.toFloat() / 255;
		Main.changed = true;
	}
	
    public function updateAll() {
		for (i in [iteration0, iteration1, param0, param1, start, balance, r1, g1, b1, r2, g2, b2, r3, g3, b3])
			i.userData[0][i.userData[1]] = i.value.toFloat() / 255;
    }

	public function serializeParams():BytesOutput
	{
		var b = new BytesOutput();
		b.writeInt16(iteration0.value);
		b.writeInt16(iteration1.value);
		b.writeInt16(param0.value);
		b.writeInt16(param1.value);
		b.writeInt16(start.value);
		b.writeInt16(balance.value);
		b.writeByte(r1.value);
		b.writeByte(g1.value);
		b.writeByte(b1.value);
		b.writeByte(r2.value);
		b.writeByte(g2.value);
		b.writeByte(b2.value);
		b.writeByte(r3.value);
		b.writeByte(g3.value);
		b.writeByte(b3.value);
		return(b);
	}
	
	public function unSerializeParams(b:BytesInput)
	{
		iteration0.value = b.readInt16();
		iteration1.value = b.readInt16();
		param0.value = b.readInt16();
		param1.value = b.readInt16();
		start.value = b.readInt16();
		balance.value = b.readInt16();
		r1.value = b.readByte();
		g1.value = b.readByte();
		b1.value = b.readByte();
		r2.value = b.readByte();
		g2.value = b.readByte();
		b2.value = b.readByte();
		r3.value = b.readByte();
		g3.value = b.readByte();
		b3.value = b.readByte();
	}

	
}