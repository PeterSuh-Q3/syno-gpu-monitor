Ext.ns('AmdGpuMonitor');
Ext.define('AmdGpuMonitor.AppInstance',{extend:'SYNO.SDS.AppInstance',appWindowName:'AmdGpuMonitor.AppWindow'});
Ext.define('AmdGpuMonitor.AppWindow',{extend:'SYNO.SDS.AppWindow',constructor:function(config){this.callParent([Ext.apply({resizable:true,maximizable:true,minimizable:true,width:1200,height:850,minWidth:760,minHeight:560,layout:'fit',border:false,items:[{xtype:'box',autoEl:{tag:'iframe',src:'/webman/3rdparty/SynoAmdGpuMonitor/index.html',frameborder:'0',style:'width:100%;height:100%;border:none;'}}]},config)]);}});
