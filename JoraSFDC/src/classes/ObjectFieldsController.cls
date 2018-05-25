public class ObjectFieldsController 
{ 
    //To Do-Try making controller private
     
    public String obj;
    public Object wsJson {get;set;}
    public List<fWrapper> objFields {get;set;}
    public  String SelectedFieldsQry {get;set;}
    public  Boolean showFields {get;set;}
    public  Boolean showCriteria {get;set;}
    public  String criteriaLabel {get;set;}
 	private PivotTableController_v1 pivotController;

    
     public ObjectFieldsController(PivotTableController_v1 x){
        showFields=false;
        showCriteria=True;
 		criteriaLabel='Hide Criteria';
        SelectedFieldsQry='';
        pivotController=x;
         
    }

    
    public void runSOQL(){
        List<AggregateResult> soqlResults=new List <AggregateResult>();
        soqlResults=Database.query(SelectedFieldsQry);
         List<Object> soqlResults2=new List <Object>();
        for (object o:soqlResults){
            String ws=Json.serialize(o);
 			Map<String,Object> o2 =  (Map<String,Object>)json.deserializeUntyped(ws);
           //Object o2=json.deserialize(ws);
            o2.remove('attributes'); 
            soqlResults2.add(o2);
             
        }
    
       
       
        pivotController.reportData =json.serialize(soqlResults2,true);
        
        
        
        pivotController.resultsAvailable=true;
    }
    
   
        public void switchShowCriteria()
    {
        showCriteria=!showCriteria;
        if (showCriteria){criteriaLabel='Hide Criteria';}
        else {criteriaLabel='Show Criteria';}
 
    }
    
    public String getobj()
    {
        return obj;
    }
    
    public void setobj(String obj)
    {
        this.obj = obj;
    }   
    
    public List<SelectOption> getobjs()
    {
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();    
        List<SelectOption> options = new List<SelectOption>();
               
        for(Schema.SObjectType f : gd)
        {
            options.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getName()));
            options.sort();
        }
        return options;
    }
  
    public void fetchFields()
    { 
        List<String> fields = new List<String>();
        Map<String , Schema.SObjectType> globalDescription = Schema.getGlobalDescribe();
        //System.debug('Selected Object is ' + obj);
        Schema.sObjectType objType = globalDescription.get(obj); 
        //System.debug('Object Type is ' + objType);
        Schema.DescribeSObjectResult r1 = objType.getDescribe(); 
        
        Map<String , Schema.SObjectField> mapFieldList = r1.fields.getMap();  

        for(Schema.SObjectField field : mapFieldList.values())  
        {  
            Schema.DescribeFieldResult fieldResult = field.getDescribe();  
            
            if(fieldResult.isAccessible())  
            {  
                System.debug('Field Name is ' + fieldResult.getName());
                fields.add(fieldResult.getName());
            }  
        }
        List<fWrapper> so = new List<fWrapper>();
        for(String f : fields)
        {
            so.add(new fWrapper(f));
        } 
        objFields=so;
        showFields=true;
        
    }   
    
    public PageReference processSelected() {
       String commaSepratedFields = '';
        String commaSepratedFields2 = '';
        Map<String,Object> ofs=new Map<String,Object>();
     for(fWrapper wf : objFields) {
      ofs.put(obj, wf);
         
            if(wf.selected == true) {
                      
             Boolean  grpble = Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap().get(wf.fld).getDescribe().isGroupable(); 
                 
                 if(commaSepratedFields == null || commaSepratedFields == ''){

                //commaSepratedFields = wf.fld;
             
                if(wf.fld.endsWith('Id') && wf.fld !='Id'){
                commaSepratedFields= wf.fld.replace('Id','.Name ')+wf.fld.replace('Id','Name');
                commaSepratedFields2= wf.fld.replace('Id','.Name ');
                }
                else{
                    if(!grpble){
                    commaSepratedFields =  'Max('+wf.fld+') ' +wf.fld;
                    commaSepratedFields2 =  '';
                    }
                else{
                    commaSepratedFields =  wf.fld;
                    commaSepratedFields2 =  wf.fld;
                    }
                     
                }
 				
                      
            }else{
                     
                //commaSepratedFields = commaSepratedFields + ', ' + wf.fld;
                if(wf.fld.endsWith('Id') && wf.fld !='Id'){
                commaSepratedFields=commaSepratedFields + ', ' + wf.fld.replace('Id','.Name ')+wf.fld.replace('Id','Name');
                commaSepratedFields2=commaSepratedFields2 + ', ' + wf.fld.replace('Id','.Name ');
                }
                else{
 
                      	if(!grpble){
                              commaSepratedFields =  commaSepratedFields + ', ' + 'Max('+wf.fld+') ' +wf.fld;
                              
                          }
                        else{
                            commaSepratedFields =  commaSepratedFields + ', ' + wf.fld;
                            commaSepratedFields2 =  commaSepratedFields2 + ', ' + wf.fld;
                        }
                }
            }
                
            }
        }
        SelectedFieldsQry= 'select ' + commaSepratedFields + ' from ' + obj +' group by ' + commaSepratedFields2;
            
 		object  xxx= json.deserializeUntyped(json.serialize(ofs));
        wsJson=xxx;
        
        system.debug(wsJson);
        return null;
    }

    
    // This is our wrapper/container class.  
	public class fWrapper {
		public String fld {get; set;}
		public Boolean selected {get; set;}

		//This is the contructor method.  
		public fWrapper(String f) {
			fld = f;
			selected = false;
		}
	}
    
    
    
    
}