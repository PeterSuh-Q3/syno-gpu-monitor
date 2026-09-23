Ext.ns('IntelGpuMonitor');
Ext.define('IntelGpuMonitor.AppInstance',{extend:'SYNO.SDS.AppInstance',appWindowName:'IntelGpuMonitor.AppWindow'});
Ext.define('IntelGpuMonitor.AppWindow',{extend:'SYNO.SDS.AppWindow',constructor:function(config){this.callParent([Ext.apply({resizable:true,maximizable:true,minimizable:true,width:1040,height:820,minWidth:760,minHeight:560,layout:'fit',border:false,items:[{xtype:'box',autoEl:{tag:'iframe',src:'/webman/3rdparty/SynoIntelGpuMonitor/index.html',frameborder:'0',style:'width:100%;height:100%;border:none;'}}]},config)]);}});
