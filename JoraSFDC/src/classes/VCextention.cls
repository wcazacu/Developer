public class VCextention {
 private VCcontroller ctrl;
     
    public VCextention(VCcontroller x){
        ctrl=x;
    }
    
    //public String getMsg(){
         
        //return ctrl.VCtxt;
        
    //} 
    
        public void updMsg(){
        
        ctrl.VCtxt= 'this is the second message';
    }
}