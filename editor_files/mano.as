var auto4:QuickObject = sim.addBox({x:15, y:8.5, width:2, height:1, angle: 0, density:1});
var auto5:QuickObject = sim.addBox({x:15, y:9.33, width:1.33, height:0.67, angle: 0, density:1});
var auto6:QuickObject = sim.addCircle({x:13.67, y:8.33, radius:0.33, density:1});
var auto7:QuickObject = sim.addCircle({x:16.33, y:8.33, radius:0.33, density:1});
var auto8:QuickObject = sim.addBox({x:17.83, y:8.17, width:2.33, height:0.33, angle: 0, density:1});
var auto9:QuickObject = sim.addBox({x:12.17, y:8.17, width:2.33, height:0.33, angle: 0, density:1});
var auto14:QuickObject = sim.addBox({x:15, y:10, width:0.67, height:0.67, angle: 0, density:1});
var auto15:QuickObject = sim.addBox({x:15, y:10.83, width:1.33, height:1, angle: 0, density:1});
var auto16:QuickObject = sim.addBox({x:15.5, y:12.33, width:0.33, height:2, angle: 0, density:1});
var auto17:QuickObject = sim.addBox({x:15.5, y:14.17, width:0.33, height:1.67, angle: 0, density:1});
var auto18:QuickObject = sim.addBox({x:14.5, y:12.33, width:0.33, height:2, angle: 0, density:1});
var auto19:QuickObject = sim.addBox({x:14.5, y:14.17, width:0.33, height:1.67, angle: 0, density:1});
var auto20:QuickObject = sim.addBox({x:14.83, y:15.83, width:2.33, height:0.33, angle: 0, density:0});
// joints:
var auto10:QuickObject = sim.addJoint({a:auto5.body, b:auto4.body, x1:15, y1:9.33, x2:15, y2:8.67});
var auto11:QuickObject = sim.addJoint({a:auto6.body, b:auto4.body, x1:13.67, y1:8.33, x2:14.33, y2:8.33});
var auto12:QuickObject = sim.addJoint({a:auto7.body, b:auto4.body, x1:16.33, y1:8.33, x2:15.67, y2:8.33});
var auto13:QuickObject = sim.addJoint({a:auto7.body, b:auto8.body, x1:16.33, y1:8.37, x2:16.93, y2:8.2});
var auto14:QuickObject = sim.addJoint({a:auto6.body, b:auto9.body, x1:13.7, y1:8.33, x2:13.13, y2:8.2});
