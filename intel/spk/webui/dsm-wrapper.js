Ext.ns('IntelGpuMonitor');
Ext.define('IntelGpuMonitor.AppInstance',{extend:'SYNO.SDS.AppInstance',appWindowName:'IntelGpuMonitor.AppWindow'});
Ext.define('IntelGpuMonitor.AppWindow',{extend:'SYNO.SDS.AppWindow',constructor:function(config){this.callParent([Ext.apply({resizable:true,maximizable:true,minimizable:true,width:760,height:620,minWidth:520,minHeight:480,layout:'fit',border:false,items:[{xtype:'box',autoEl:{tag:'iframe',src:'/webman/3rdparty/SynoIntelGpuMonitor/index.html',frameborder:'0',style:'width:100%;height:100%;border:none;'}}]},config)]);}});
