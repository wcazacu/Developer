public with sharing class PivotObjectPicklist {
     
    public List<SelectOption> availableReports { get; set; }
    public Id reportId { get; set; }
    public Id instanceId { get; set; }
    public Boolean reportIsRunning { get; set; }
    private transient Reports.ReportResults reportResults;
   
    
    public PivotObjectPicklist() {
        availableReports = retrieveAvailableReports();
    }
    
    public List<SelectOption> retrieveAvailableReports() {
        List<SelectOption> reptOpts = new List<SelectOption>();
        for (Report r : [
             Select Id, Name
             From Report
             Where Format = 'Tabular'
             Order By Name
        ]) {
            reptOpts.add(new SelectOption(r.Id, r.Name));
        }
        return reptOpts;
    }

        public PageReference runReport() {
            VT_ReportResultsHelper rh=new VT_ReportResultsHelper();
 		rh.getReportResponse(reportID);
        
        return null;
    }
         
}