public with sharing class WhiteboardController { 
    
    public String WhiteboardId { get; set; }
    public String WhiteboardIdPersonal { get; set; }
    public String ItemId { get; set; }
    
    public List<User> AllUsers { get; set;}
    public List<User> filterUser { get; set; }
    public List<SelectOption> filterSelect { get; set; }
    public User userSelect { get; set; }
    
    public String assignedUser { get; set; }
    
    public Whiteboard_Item_Activity__c activity { get; set; }
    public Whiteboard_Item__c Item { get; set; }
    
    public List<Whiteboard_Item__c> currentItems { get; set;}
    public List<Whiteboard_Item__c> trashItems { get; set; }
    public List<Whiteboard_Item__c> completedItems { get; set; }
    
    public String currentWhiteboard { get; set; }
    public String currentWhiteboardTrash { get; set; }
    public Boolean indicator { get; set; }  // true if company, false if personal
    public String show { get; set; }
    public String companyName { get; set; }
    public String userName { get; set; }
    
    public String searchValue { get; set; }        //filter by search bar text
    public String itemOrActivity { get ; set; }     // filter by item or activity
    public Boolean itemActBool { get; set; }        // true if item, false if act
    public String Priority { get; set; }            // filter item by priority
    public Boolean priorityBool { get; set; }
    public String TimeFrame { get; set; }           // filter item by time frame   
    public Date startDate { get; set; }
    public Date endDate { get; set; }

    public Opportunity o = new Opportunity();
    public Opportunity getProxyObject() { return o; }   

   public List<Whiteboard_Item__c> results { get; set; }        // holds final filter results
   public List<Whiteboard_Item__c> listResults {get; set; }     //holds initial filter results as a list
   
    public List<Whiteboard_Item__c> completedResults { get; set; }        // holds final completedResults filter results
   public List<Whiteboard_Item__c> completedListResults {get; set; }     //holds initial completedResults filter results as a list
    
    public Boolean editIndicator {get; set;}
    public Boolean editActivityIndicator {get; set;}


    // ************************ SETTING UP CONTROLLER AND POPULATING LISTS ****************************************************************
    
    public WhiteboardController() {

        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
        currentItems = new List<Whiteboard_Item__c>();
        trashItems = new List<Whiteboard_Item__c>();
        completedItems = new List<Whiteboard_Item__c>();
        results = new List<Whiteboard_Item__c>();
        completedResults = new List<Whiteboard_Item__c>();
 
        Item = new Whiteboard_Item__c();
        activity = new Whiteboard_Item_Activity__c();
        getCompanyItems();
        indicator = true; 
        editIndicator = false;
        editActivityIndicator = false;
        setBoardTitle(indicator);
        
        filterSelect = new List<SelectOption>();
        filterUser = new List<User>();
        getUserForFilter();
        AllUsers = new List<User>();
        assignedUser = null; 
        searchValue = '';  
    }
    
///////Side bar methods//////////       
    public List<SelectOption> getItemTask(){ //creates selection options for item v. task select list
         List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('NONE', '--Type--'));
            options.add(new SelectOption('ITEM', 'Items'));
            options.add(new SelectOption('ACTIVITY','Activities'));
            return options;
    }

   public List<SelectOption> getItems() { //creates selection options for priorities
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('NONE', '--Priority--'));
            options.add(new SelectOption('HIGH','High Priority'));
            options.add(new SelectOption('NOPRIORITY','No Priority'));
            return options;
    }
          
    public List<SelectOption> getItemsTwo() { //creates selection options for date selectList
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('NONE', '--Due Date--'));
            options.add(new SelectOption('TODAY', 'Today'));
            options.add(new SelectOption('TOMORROW', 'Tomorrow'));
            options.add(new SelectOption('THISWEEK','This Week'));
            options.add(new SelectOption('NEXTWEEK','Next Week'));
            options.add(new SelectOption('THISMONTH','This Month'));
            options.add(new SelectOption('NEXTMONTH','Next Month'));
            options.add(new SelectOption('PAST', 'Past Due'));
            return options;
    }

    public PageReference filter() {
    
                    
        results.clear();
        completedResults.clear();        
        setFilterBools();
        
        getPersonalOrCompany();
        searchItems();
        filterItemsOrActs();
        filterPriority();
        filterTimeFrame();
        dateSearch();
        
        getPersonalOrCompanyTwo();       
        searchItemsTwo();
        filterItemsOrActsTwo();
        filterPriorityTwo();
        filterTimeFrameTwo();
        dateSearchTwo();    
        return null;
    }
    
    public void setFilterBools() {
        getUserForFilter();
        
        if (Priority == 'HIGH') {
            priorityBool = true;
        } else if (Priority == 'NOPRIORITY') {
            priorityBool = false;
        } else {
            priorityBool = null;   
        }
        
        if (itemOrActivity == 'ITEM') {
            itemActBool = true;   
        } else if (itemOrActivity == 'ACTIVITY') {
            itemActBool = false;   
        } else {
            itemActBool = null;   
        }
        
  if(TimeFrame == 'NONE') {
    startDate = null;
    endDate = null;
  } else if (TimeFrame == 'TODAY') {
    startDate = Date.today();
    endDate = Date.today().addDays(1);
  } else if (TimeFrame == 'TOMORROW') {
    startDate = Date.today().addDays(1);
    endDate = Date.today().addDays(2);
  } else if (TimeFrame == 'THISWEEK') {
    startDate = Date.today();
    endDate = Date.today().toStartofWeek().addDays(7);
  } else if (TimeFrame == 'NEXTWEEK') {
    startDate = Date.today().toStartofWeek().addDays(7);
    endDate = startDate.addDays(7);
  } else if (TimeFrame == 'THISMONTH') {
    startDate = Date.today();
    endDate = Date.today().toStartOfMonth().addMonths(1);
  } else if (TimeFrame == 'NEXTMONTH') {
    startDate = Date.today().toStartofMonth().addMonths(1);
    endDate = startDate.addMonths(1);
  } else if (TimeFrame == 'PAST') {
    startDate = date.newInstance((Date.today().year() - 10), date.today().month(), (date.today().day() - 1));
    endDate = date.newInstance(Date.today().year(), date.today().month(), (date.today().day()));
  }
}
    
public void addToResults(List<Whiteboard_Item__c> inList) {
    List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
    
    if (results.size() == 0) {
        results.addAll(inList);
        currentItems = results;
        return;
    } else {
        for(Whiteboard_Item__c item1 : currentItems) {
            Integer location = -1;
            List<Whiteboard_Item_Activity__c> activities = new List<Whiteboard_Item_Activity__c>();
            for(Integer item2 = 0; item2 < inList.size(); item2++) {
                if(item1.id == inList.get(item2).id) {
                    location = item2;
                    for(Whiteboard_Item_Activity__c act1: item1.Whiteboard_Item_Activities__r){
                        for(Whiteboard_Item_Activity__c act2: inList.get(item2).Whiteboard_Item_Activities__r){
                            if(act1.id == act2.id){
                                activities.add(act1);
                            }
                        }
                    }
                }
            }
            if (location != -1) {
                Whiteboard_Item__c toAdd = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE Id IN :activities
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)          
                      FROM Whiteboard_Item__c
                      WHERE Id =: inList.get(location).Id
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 1]; 
                Boolean add = checkItem(toAdd);
                if (add) {
                    
                    tempList.add(toAdd);
                }
            }
        }
        results.addAll(tempList);
        currentItems = tempList;
    }
}
    
    public Boolean checkItem(Whiteboard_Item__c item) {
        if (priorityBool != null) {
            if ((priorityBool == true && item.High_Priority__c == true) || (priorityBool == false && item.High_Priority__c == false) || (priorityBool == false && item.High_Priority__c == true && item.Whiteboard_Item_Activities__r.size() > 0) || (priorityBool == true && item.High_Priority__c == false && item.Whiteboard_Item_Activities__r.size() > 0)) {
                return checkItemAct(item);
            }
        } else {
            return checkItemAct(item);
        }
        return false;
    }
    
    public Boolean checkItemAct(Whiteboard_Item__c item) {
        if (itemActBool != null) {
            if (itemActBool == true || (itemActBool == false && item.Whiteboard_Item_Activities__r.size() > 0)) {
                return checkItemDate(item);   
            }
        } else {
            return checkItemDate(item);
        }
        return false;
    }
    
    
    public Boolean checkItemDate(Whiteboard_Item__c item) {
        if (o.closeDate != null) {
            if (item.Item_Due_Date__c == o.closeDate || (item.Whiteboard_Item_Activities__r.size() > 0)) {
                return checkSearch(item);   
            }
        } else {
            return checkSearch(item);
        }
        return false;
    }
    
    public Boolean checkSearch(Whiteboard_Item__c item) {
        if (searchValue != '') {
            String databaseSearch = '%' + searchValue + '%';
            Boolean inTitle = false;
            Boolean inAssignedTo = false;
            inTitle = String.ValueOf(item.Name).containsIgnoreCase(searchValue);
            if(item.assignedTo__r.Name != null){
            inAssignedTo = String.ValueOf(item.assignedTo__r.Name).containsIgnoreCase(searchValue);
            }            
            if(inTitle == true ||inAssignedTo == true || item.Whiteboard_Item_Activities__r.size() > 0){
                return true;   
            }
            return false;
        }
        return true;
    }
    
    
    public void getPersonalOrCompany() {
    
    
    if(indicator == false){
    List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
    tempList = [SELECT Name, Id, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Completed_Date__c, Item_Due_Date__c, Past_Due__c,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Id, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c,  actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
    addToResults(tempList);
    
    }
    
    }
    
    public PageReference searchItems(){//When you type in the search bar, this method is called
   
        String databaseSearch = '%' + searchValue + '%';
        
        List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
        tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c !=: indicator AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)    
                    FROM Whiteboard_Item__c
                    WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                    ORDER BY High_Priority__c DESC, CreatedDate
                    LIMIT 100]; 

        addToResults(tempList);
        return null;
    }

    

    public void dateSearch() {  //Used when a specific date is entered in the sidebar
        List<Whiteboard_Item__c> tempSet = new List<Whiteboard_Item__c>();
        
        if (o.closeDate == null) {
            addToResults(getAllItems());
            return;
        } else {
            tempSet = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Past_Due__c,
                            (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c =: o.closeDate
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)    
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100]; 
    
            
            addToResults(tempSet);

            return;
        }
    }

    public void filterItemsOrActs() {
    
      List<Whiteboard_Item__c> tempSet = new List<Whiteboard_Item__c>();
      List<Whiteboard_Item__c> specialCase = new List<Whiteboard_Item__c>();
    
        if (itemOrActivity == 'NONE') {
            addToResults(getAllItems());
            return;
        } else if (itemOrActivity == 'ITEM') {
            tempSet = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Past_Due__c,
                            (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND id =: 'xct345'
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)    
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100]; 
    
            addToResults(tempSet);
            return;
    
        } else if (itemOrActivity == 'ACTIVITY') {
            tempSet = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Activities__c >: 0
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
        
            List<Whiteboard_Item__c> keep = new List<Whiteboard_Item__c>(); 
            for (Whiteboard_Item__c i : tempSet) {
                if (i.Whiteboard_Item_Activities__r.size() != 0) {
                    keep.add(i);
                }
            }
            addToResults(keep);
            return;
        }   
    }
    
    
    
    public void filterPriority() {
        if (Priority == 'NONE') {
            addToResults(getAllItems());
            return;
        }
    
        List<Whiteboard_Item__c> items = [SELECT Name, Id, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Completed_Date__c, Item_Due_Date__c, Past_Due__c,
            (SELECT Name, Due_Date__c, Description__c, Trashed__c, Id, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c,  actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
             FROM Whiteboard_Item_Activities__r
             WHERE High_Priority__c =: priorityBool AND PersonalItem__c !=: indicator
             ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
             LIMIT 30)
        FROM Whiteboard_Item__c
        WHERE PersonalItem__c !=: indicator
        ORDER BY High_Priority__c DESC, CreatedDate];
   
       
        addToResults(items);
    }
    
       public void filterTimeFrame() {
        
        if (startDate == null) {
            addToResults(getAllItems());
            return;
        }
        
      List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
      List<Whiteboard_Item__c> specialCase = new List<Whiteboard_Item__c>();
      
      if(priorityBool == null){      
        tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
    
        specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Activities__c > 0
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
    }
    
        if(priorityBool == true){  
    
        tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: true
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
    
        specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: true
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Activities__c > 0
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
    } 
    
    if(priorityBool == false){  
    
        tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: false
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
    
        specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: false
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Activities__c > 0
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
    }                                           
                          
   if(itemActBool == null || itemActBool == false){
        for (Whiteboard_Item__c i : specialCase) {
          if (i.Whiteboard_Item_Activities__r.size() > 0) {
                tempList.add(i);
            }
        }
        }

        addToResults(tempList);
    }
    
    public PageReference clearSearch() {

        itemOrActivity = 'NONE';
        itemActBool = null;
        Priority = 'NONE';
        priorityBool = null;
        TimeFrame = 'NONE';
        startDate = null;
        endDate = null;
        o.closeDate = null;
        searchValue = '';
        currentItems = getAllItems();
        completedItems = getAllCompletedItems();
        
        return null;
    }

//////additional search bar code to allow for filtering completedItems    
 public List<Whiteboard_Item__c> getAllCompletedItems() {
    List<Whiteboard_Item__c> allItems = new List<Whiteboard_Item__c>();
    if(indicator == true){
        allItems =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c !=: indicator
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
    }else if(indicator == false){
            allitems = [SELECT Name, Id, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Completed_Date__c, Item_Due_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Id, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c,  actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
    }
return allItems;
    }

public void addToResultsTwo(List<Whiteboard_Item__c> inList) {
    List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
    if (completedResults.size() == 0) {
        completedResults.addAll(inList);
        completedItems = completedResults;
        return;
    } else {
        for(Whiteboard_Item__c item1 : completedItems) {
            Integer location = -1;
            List<Whiteboard_Item_Activity__c> activities = new List<Whiteboard_Item_Activity__c>();
            for(Integer item2 = 0; item2 < inList.size(); item2++) {
                if(item1.id == inList.get(item2).id) {
                    location = item2;
                    for(Whiteboard_Item_Activity__c act1: item1.Whiteboard_Item_Activities__r){
                        for(Whiteboard_Item_Activity__c act2: inList.get(item2).Whiteboard_Item_Activities__r){
                            if(act1.id == act2.id){
                                activities.add(act1);
                            }
                        }
                    }
                }
            }
            if (location != -1) {
                Whiteboard_Item__c toAdd = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Past_Due__c, Completed_Date__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE Id IN :activities
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)          
                      FROM Whiteboard_Item__c
                      WHERE Id =: inList.get(location).Id
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 1]; 
                Boolean add = checkItemTwo(toAdd);
                if (add) {
                    tempList.add(toAdd);
                }
            }
        }
        completedResults.addAll(tempList);
        completedItems = tempList;
    }
}
    
    public Boolean checkItemTwo(Whiteboard_Item__c item) {
        if (priorityBool != null) {
            if ((priorityBool == true && item.High_Priority__c == true) || (priorityBool == false && item.High_Priority__c == false) || (priorityBool == false && item.High_Priority__c == true && item.Whiteboard_Item_Activities__r.size() > 0) || (priorityBool == true && item.High_Priority__c == false && item.Whiteboard_Item_Activities__r.size() > 0)) {
                return checkItemActTwo(item);
            }
        } else {
            return checkItemActTwo(item);
        }
        return false;
    }
    
    public Boolean checkItemActTwo(Whiteboard_Item__c item) {
        if (itemActBool != null) {
            if (itemActBool == true || (itemActBool == false && item.Whiteboard_Item_Activities__r.size() > 0)) {
                return checkItemDateTwo(item);   
            }
        } else {
            return checkItemDateTwo(item);
        }
        return false;
    }
    
    
    public Boolean checkItemDateTwo(Whiteboard_Item__c item) {
        if (o.closeDate != null) {
            if (item.Item_Due_Date__c == o.closeDate || (item.Whiteboard_Item_Activities__r.size() > 0)) {
                return checkSearchTwo(item);   
            }
        } else {
            return checkSearchTwo(item);
        }
        return false;
    }
    
    public Boolean checkSearchTwo(Whiteboard_Item__c item) {
       if (searchValue != '') {
            String databaseSearch = '%' + searchValue + '%';
            Boolean inTitle = false;
            Boolean inAssignedTo = false;
            inTitle = String.ValueOf(item.Name).containsIgnoreCase(searchValue);
            if(item.assignedTo__r.Name != null){
            inAssignedTo = String.ValueOf(item.assignedTo__r.Name).containsIgnoreCase(searchValue);
            }            
            if(inTitle == true ||inAssignedTo == true || item.Whiteboard_Item_Activities__r.size() > 0){
                return true;   
            }
            return false;
        }
        return true;
    }
    
    public void getPersonalOrCompanyTwo() {
    
    
    if(indicator == false){
    List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
    tempList = [SELECT Name, Id, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Completed_Date__c, Item_Due_Date__c, Past_Due__c,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Id, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c,  actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true AND Completed__c =: true
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
    addToResultsTwo(tempList);
    
    }
    
    }
    
    
    public PageReference searchItemsTwo(){//When you type in the search bar, this method is called
   
        String databaseSearch = '%' + searchValue + '%';
        
        List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
        tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Past_Due__c, Completed_Date__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c !=: indicator AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)    
                    FROM Whiteboard_Item__c
                    WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                    ORDER BY High_Priority__c DESC, CreatedDate
                    LIMIT 100]; 

        addToResultsTwo(tempList);
        return null;
    }

    

    public void dateSearchTwo() {  //Used when a specific date is entered in the sidebar
        List<Whiteboard_Item__c> tempSet = new List<Whiteboard_Item__c>();
        
        if (o.closeDate == null) {
            addToResultsTwo(getAllCompletedItems());
            return;
        } else {
            tempSet = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Past_Due__c, Completed_Date__c,
                            (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c =: o.closeDate
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)    
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100]; 
    
            addToResultsTwo(tempSet);
            return;
        }
    }

    public void filterItemsOrActsTwo() {
    
      List<Whiteboard_Item__c> tempSet = new List<Whiteboard_Item__c>();
      List<Whiteboard_Item__c> specialCase = new List<Whiteboard_Item__c>();
    
        if (itemOrActivity == 'NONE') {
            addToResultsTwo(getAllCompletedItems());
            return;
        } else if (itemOrActivity == 'ITEM') {
            tempSet = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Past_Due__c, Completed_Date__c,
                            (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND id =: 'xct345'
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)    
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100]; 
    
            addToResultsTwo(tempSet);
            return;
    
        } else if (itemOrActivity == 'ACTIVITY') {
            tempSet = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Past_Due__c, Completed_Date__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Activities__c >: 0
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
        
            List<Whiteboard_Item__c> keep = new List<Whiteboard_Item__c>(); 
            for (Whiteboard_Item__c i : tempSet) {
                if (i.Whiteboard_Item_Activities__r.size() != 0) {
                    keep.add(i);
                }
            }
            addToResultsTwo(keep);
            return;
        }   
    }
    
    
    
    public void filterPriorityTwo() {
        if (Priority == 'NONE') {
            addToResultsTwo(getAllCompletedItems());
            return;
        }
    
        List<Whiteboard_Item__c> items = [SELECT Name, Id, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Completed_Date__c, Item_Due_Date__c, Past_Due__c,
            (SELECT Name, Due_Date__c, Description__c, Trashed__c, Id, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c,  actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
             FROM Whiteboard_Item_Activities__r
             WHERE High_Priority__c =: priorityBool AND PersonalItem__c !=: indicator
             ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
             LIMIT 30)
        FROM Whiteboard_Item__c
        WHERE PersonalItem__c !=: indicator
        ORDER BY High_Priority__c DESC, CreatedDate];
    
        addToResultsTwo(items);
    }
    
       public void filterTimeFrameTwo() {
        
        if (startDate == null) {
            addToResultsTwo(getAllCompletedItems());
            return;
        }
        
      List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
      List<Whiteboard_Item__c> specialCase = new List<Whiteboard_Item__c>();
      
      if(priorityBool == null){      
        tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
    
        specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Activities__c > 0
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
    }
    
        if(priorityBool == true){  
    
        tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: true
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
    
        specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: true
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Activities__c > 0
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
    } 
    
    if(priorityBool == false){  
    
        tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: false
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
    
        specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: false
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Activities__c > 0
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
    }                                           
                          
   if(itemActBool == null || itemActBool == false){
        for (Whiteboard_Item__c i : specialCase) {
          if (i.Whiteboard_Item_Activities__r.size() > 0) {
                tempList.add(i);
            }
        }
        }

        addToResultsTwo(tempList);
    }

//end of completedItems Search code


//////end of sidebar methods////////////////////////////////    
 
    public void getUserForFilter() {
        filterUser = [SELECT Name, LastName, Id, FirstName, Username, Email FROM User];
        filterSelect.add(new SelectOption('', 'None'));
        for (User u : filterUser) {
            filterSelect.add(new SelectOption(u.Id, u.Name));
        }
    }
    
    public List<SelectOption> getUserList() {
        AllUsers = [Select Name, LastName, Id, FirstName, Username, Email From User];   
        
        List<SelectOption> UserList = new List<SelectOption>();
        
        if(Item.assignedTo__c != null) {
            String userName = [SELECT Name FROM User WHERE Id =: Item.assignedTo__c LIMIT 1].Name;
            UserList.add(new SelectOption(Item.assignedTo__c, userName));
        }
        
        UserList.add(new SelectOption('', 'None'));
        
        for(User temp : AllUsers)
        {
            //Only add the name if it is not the same Id as the current User
            if (Item.assignedTo__r.name != '' && temp.Id != Item.assignedTo__c) {
                UserList.add(new SelectOption(temp.Id, temp.Name));
            }
        }
        
        return UserList;
    }
    
    public void setBoardTitle(Boolean board) {
        if (board) {     
            //companyName = [SELECT Name FROM Organization LIMIT 1].Name;
           
                currentWhiteboard = 'Company Whiteboard';
            
        } else {
            //userName = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()].Name;
          
                currentWhiteboard = 'Personal Whiteboard';
            
        }
    }
    
public List<Whiteboard_Item__c> getAllItems() {
    List<Whiteboard_Item__c> allItems = new List<Whiteboard_Item__c>();
    
    if(indicator == true){
        allItems =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
    }else if(indicator == false){
             
        allitems = [SELECT Name, Id, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Completed_Date__c, Item_Due_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Id, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c,  actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
    }
                      
return allItems;
}
    
    public void getCompanyItems() {
        //currentWhiteboard = 'Company Whiteboard';
        
  
        currentItems =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
        indicator = true;
        setBoardTitle(indicator);

        itemOrActivity = 'NONE';
        priority = 'NONE';
        timeFrame = 'NONE';
        
        getCompanyCompleted();
    }              

    public void getCompanyCompleted() {  
        completedItems = [SELECT Name, Id, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c, OwnerId, assignedTo__c, assignedTo__r.Name, Completed_Date__c,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c,  actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false 
                          ORDER BY CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: true
                      ORDER BY CreatedDate
                      LIMIT 100];   
    }
    
    public void getPersonalItems() {
        currentWhiteboard = 'Personal Whiteboard';
        currentItems = [SELECT Name, Id, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Completed_Date__c, Item_Due_Date__c, Past_Due__c,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Id, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c,  actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
        indicator = false;
        setBoardTitle(indicator);
        getPersonalCompleted();

         itemOrActivity = 'NONE';
        priority = 'NONE';
        timeFrame = 'NONE';
    }
    
    public void getPersonalCompleted() {  
                      
        completedItems = [SELECT Name, Id, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c, OwnerId, assignedTo__c, assignedTo__r.Name, Completed_Date__c,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c,  actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true
                          ORDER BY CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true AND Completed__c =: true
                      ORDER BY CreatedDate
                      LIMIT 100];                      
    }
    
    // ********************************************************************************************************************************
    
    // ************************ DELETING ITEMS AND ACTIVITIES ****************************************************************

    public PageReference clearActivity() {
        activity = new Whiteboard_Item_Activity__c();
        editIndicator = false;
        
        return null;
    }
    
    public PageReference clearItem() {
        Item = new Whiteboard_Item__c();
        editIndicator = false;
        
        return null;
    }

    public void completeAct() {
        List<Whiteboard_Item_Activity__c> completed = [SELECT Id, Name, Completed__c, CompletedBy__c, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        for (Whiteboard_Item_Activity__c act : completed) {
            act.Completed__c = true;   
            act.Completed_Date__c = date.today();
            act.Completedby__c = UserInfo.getUserId();
        }
        
        try {
             update completed;
             if (indicator) {
                    getCompanyItems();
                } else {
                    getPersonalItems();
                }  
        }
        catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
        return;
    }
    
    public void completeItem() {
        
        //Get the selected item
        List<Whiteboard_Item__c> itemsToComplete = [SELECT id, name, Completed__c, Completedby__c, OwnerId,
                                                     (SELECT Name, Id, Completedby__c, CompletedBy__r.Name, Completed__c, Completed_Date__c
                                                      FROM Whiteboard_Item_Activities__r
                                                      WHERE PersonalItem__c =: false 
                                                      LIMIT 30)
                                                    from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
        
        Id userid = UserInfo.getUserId();
        //Check the "Completed" checkbox on that item
        for(Whiteboard_Item__c item : itemsToComplete) {
            item.Completed__c = true;
            item.CompletedBy__c = userid;
            item.Completed_Date__c = date.today();

        }
        
        update itemsToComplete;
        
        if (indicator) {
            getCompanyItems();
        } else {
            getPersonalItems();
        } 
        
        return;
    }
    
    public void unCompleteItem() {
        
        //Get the selected item
        List<Whiteboard_Item__c> itemsToUnComplete = [SELECT id, name, Completed__c, CompletedBy__c, OwnerId,
                                                        (SELECT Name, Id, Completedby__c, CompletedBy__r.Name, Completed__c, Completed_Date__c
                                                          FROM Whiteboard_Item_Activities__r
                                                          WHERE PersonalItem__c =: false 
                                                          LIMIT 30)
                                                      from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
        
        //UnCheck the "Completed" checkbox on that item
        for(Whiteboard_Item__c item : itemsToUnComplete) {
            item.Completed__c = false;
            item.Completedby__c = null;
            item.completed_Date__c = null;
            

            update item.Whiteboard_Item_Activities__r;
        }
                    
        update itemsToUnComplete;
        
        if (indicator) {
            getCompanyItems();
        } else {
            getPersonalItems();
        } 
        
        return;
    }
    
    public void uncompleteAct() {
        List<Whiteboard_Item_Activity__c> completed = [SELECT Id, Name, Completed__c, CompletedBy__c, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        for (Whiteboard_Item_Activity__c act : completed) {
            act.Completed__c = false;  
            act.CompletedBy__c = null;
            act.Completed_Date__c = null;
        }
        
        try {
             update completed;
             if (indicator) {
                    getCompanyItems();
                } else {
                    getPersonalItems();
                }  
        }
        catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
        return;
    }
    
    
    public void setPriority()  {
        //Get the selected item
        List<Whiteboard_Item__c> itemsToGivePriority = [SELECT id, name, High_Priority__c from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
        
        //Check the "High Priority" checkbox on that item
        for(Integer i=0; i < itemsToGivePriority.size(); i++)
        {
            itemsToGivePriority[i].High_Priority__c = true;
        }
        update itemsToGivePriority;
        
        if (indicator) {
            getCompanyItems();
        } else {
            getPersonalItems();
        } 
        
        return;
    }
    
    public void unsetPriority()  {
        //Get the selected item
        List<Whiteboard_Item__c> itemsToGivePriority = [SELECT id, name, High_Priority__c from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
        
        //unCheck the "HighPriority" checkbox on that item
        for(Integer i=0; i < itemsToGivePriority.size(); i++)
        {
            itemsToGivePriority[i].High_Priority__c = false;
        }
        update itemsToGivePriority;
        
        if (indicator) {
            getCompanyItems();
        } else {
            getPersonalItems();
        } 
        
        return;
    }
    
    public void setActPriority()  {
        //Get the selected item
        List<Whiteboard_Item_Activity__c> actToGivePriority = [SELECT Id, Name, High_Priority__c, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        
        //Check the "High Priority" checkbox on that activity
        for(Integer i=0; i < actToGivePriority.size(); i++)
        {
            actToGivePriority[i].High_Priority__c = true;
        }
        update actToGivePriority;
        
        if (indicator) {
            getCompanyItems();
        } else {
            getPersonalItems();
        } 
        
        return;
    }

    public void unsetActPriority()  {
        //Get the selected item
        List<Whiteboard_Item_Activity__c> actToGivePriority = [SELECT Id, Name, High_Priority__c, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        
        //unCheck the "High Priority" checkbox on that activity
        for(Integer i=0; i < actToGivePriority.size(); i++)
        {
            actToGivePriority[i].High_Priority__c = false;
        }
        update actToGivePriority;
        
        if (indicator) {
            getCompanyItems();
        } else {
            getPersonalItems();
        } 
        
        return;
    }

    public void deleteItem() {

        List<Whiteboard_Item__c> goners = [SELECT id, name from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];

            try {
                delete goners;
                if (indicator) {
                    getCompanyItems();
                } else {
                    getPersonalItems();
                }              
            }            
            catch(Exception ex) {
                ApexPages.addMessages(ex);
            }              
        return;
    }
    
    public void deleteAct() {
        List<Whiteboard_Item_Activity__c> goners = [SELECT Id, Name, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        try {
             delete goners;
             if (indicator) {
                    getCompanyItems();
                } else {
                    getPersonalItems();
                }  
        }
        catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
        return;
    }
    

    
    public PageReference editItem() {
        //Set edit boolean to true
        editIndicator = true;
        
        List<Whiteboard_Item__c> Items = [SELECT Id, Name, High_Priority__c, Item_Due_Date__c, assignedTo__r.Name from Whiteboard_Item__c where Id = :ApexPages.currentpage().getparameters().get('ItemId')];
        if (Items.size() > 0) {
            Item = Items.get(0);
        }
        getUserList();                  

        return null;
    }
    
    public PageReference editActivity() {
        //Set edit boolean to true
        editIndicator = true;

        List<Whiteboard_Item_Activity__c> Activities = [SELECT Id, Name, High_Priority__c, Due_Date__c, actAssignedTo__r.Name, Description__c, Completed_Date__c from Whiteboard_Item_Activity__c where Id = :ApexPages.currentpage().getparameters().get('activityId')];

        if (Activities.size() > 0) {
            activity = Activities.get(0);
        }
        getUserList();                  

        return null;
    }
    
    public PageReference reset() {
        editIndicator = false;
        Item = new Whiteboard_Item__c();
        activity = new Whiteboard_Item_Activity__c();
        assignedUser = null;
        return null;
    }


    // ********************************************************************************************************************************
    
    public Whiteboard_Item__c[] getWhiteboard() {

        return [SELECT Name, Id,
                     (SELECT Name, Due_Date__c, Description__c, Id, Completed_Date__c
                      FROM Whiteboard_Item_Activities__r
                      WHERE PersonalItem__c =: false 
                      ORDER BY CreatedDate 
                      LIMIT 30)
                  FROM Whiteboard_Item__c
                  WHERE PersonalItem__c =: false
                  ORDER BY CreatedDate
                  LIMIT 100];
    }
    
    public Whiteboard_Item__c[] getPersonalWhiteboard() {
    
        return [SELECT Name, Id,
                         (SELECT Name, Due_Date__c, Description__c, Id, Completed_Date__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true
                          ORDER BY CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true
                      ORDER BY CreatedDate
                      LIMIT 100];
    }
    
    // ************************ SAVING ITEMS AND ACTIVITIES ****************************************************************
    
    public void save() {
        System.debug('Entered global save');                                            
        
        if(indicator)  {
           saveCompany(); 
        } else {
            savePersonal();
        }                  
    }
    
    
    public PageReference saveCompany() {
        System.debug('Entered save block');
        if (Item.Name == '' || Item.Name == null) {
            return null;   
        }
        try {
            System.debug('Item: ' + Item);
            System.debug('Assigned User: ' + assignedUser);

            if (assignedUser == '') {
                System.debug('No User');
            } else {
                List<User> users = [SELECT Name, Id FROM User WHERE Id =: assignedUser LIMIT 1];
                if (users.size() > 0) {
                    Item.assignedTo__r = users.get(0);
                    System.debug('User: ' + users.get(0));
                    Item.assignedTo__c = assignedUser;
                }
            }
            System.debug(Item);
            
            //If edit boolean is true, update, otherwise insert
            if(editIndicator == true)
            {
                Item.assignedTo__c = assignedUser;
                update Item;
            }
            else
            {insert Item;} 
            
            Item = new Whiteboard_Item__c();
            getUserList();
            assignedUser = null;
            getCompanyItems();         
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        
        editIndicator = false;
        
        
        return null;
    }
    
    public void saveAct() {                
        if(indicator)  {
           saveActCompany(); 
        } else {
            saveActPersonal();
        } 
    }
    
    public PageReference saveActCompany() {

        if (!editIndicator) {
            activity.Whiteboard_Item__c = WhiteboardId;
        }
        if (activity.Name == '' || activity.Name == null) {
            return null;   
        }
        try {
            
            if(editIndicator == true)
            {update activity;}
            else
            {insert activity;} 
            
            
            activity = new Whiteboard_Item_Activity__c();
            getUserList();
            assignedUser = null;
            
            getCompanyItems();
        }                
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        editIndicator = false;
        return null;
    }
    
    public PageReference savePersonal() {
        if (Item.Name == '' || Item.Name == null) {
            return null;   
        }
        try {
            Item.PersonalItem__c = true;
            if (assignedUser == '') {
                // no user   
            } else {
                List<User> users = [SELECT Name, Id FROM User WHERE Id =: assignedUser LIMIT 1];
                if (users.size() > 0) {
                    Item.assignedTo__r = users.get(0);
                    System.debug('User: ' + users.get(0));
                    Item.assignedTo__c = assignedUser;
                }
            }
            //If edit boolean is true, update, otherwise insert
            if(editIndicator == true) {
                Item.assignedTo__c = assignedUser;
                update Item;                
            } else {
                insert Item;
            }
            
            Item = new Whiteboard_Item__c();
            getUserList();
            assignedUser = null;
            getPersonalItems();         
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        editIndicator = false;
        return null;
    }
    
    public PageReference saveActPersonal() {
        if (!editIndicator) 
            activity.Whiteboard_Item__c = WhiteboardId;
        if (activity.Name == '' || activity.Name == null) {
            return null;   
        }
        try {           
            if (editIndicator == true) {
                update activity;
            } else {
                activity.PersonalItem__c = true;
                insert activity;
            }
            activity = new Whiteboard_Item_Activity__c();
            getUserList();
            assignedUser = null;
            getPersonalItems();
        }                
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        editIndicator = false;
        return null;
    }    

    // ********************************************************************************************************************************
    
    public void setItem(Whiteboard_Item__c newItem) {
        Item = newItem;
        return;
    }
    
    public void setAct(Whiteboard_Item_Activity__c newAct) {
        activity = newAct;
        return;
    }
    
    public void setWhiteboardId(Id wbId) {
        WhiteboardId = wbId;
        return;
    }
    
    @IsTest
    static void testWhiteboardCtrl()
    {
        WhiteboardController controller = new WhiteboardController();                
        
        Whiteboard_Item__c item = new Whiteboard_Item__c(Name = 'Item One');
        controller.setItem(item);
        Integer currentSize = controller.getWhiteboard().size();
        currentSize++;
        controller.save();
        System.assertEquals(currentSize, controller.getWhiteboard().size());
        ApexPages.currentpage().getParameters().put('ItemId', item.Id);
        controller.deleteItem();
        currentSize--;
        System.assertEquals(currentSize, controller.getWhiteboard().size());
        
        controller.setWhiteboardId(item.Id);
        Whiteboard_Item_Activity__c act = new Whiteboard_Item_Activity__c(Name = 'Act One');
        controller.setAct(act);
        
        controller.saveAct();
        controller.saveActPersonal();
        ApexPages.currentpage().getParameters().put('ActId', act.Id);
        controller.deleteAct();
        controller.getPersonalWhiteboard();
             
        
        
        //System.assertEquals(null, controller.deleteItem());
        
        //System.assertEquals(null, controller.deleteAct());
        
        //Whiteboard_Item__c[] w = [SELECT Name, Id, (select Name, Due_Date__c, Description__c, Completed_Date__c from Whiteboard_Item_Activities__r order by CreatedDate)
         //                         from Whiteboard_Item__c order by CreatedDate];
        //System.assertEquals(w[0].Name, controller.getWhiteboard()[0].Name);
        
        //System.assertEquals(null, controller.save());
        
        //System.assertEquals(null, controller.saveaCT());
    }
}