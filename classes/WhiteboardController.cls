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
        itemOrActivity = 'NONE';
        priority = 'NONE';
        timeFrame = 'NONE';     
    }  
 
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
        searchValue = '';
        itemOrActivity = 'NONE';
        priority = 'NONE';
        timeFrame = 'NONE'; 
        
        filter();

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
        
        searchValue = '';
        itemOrActivity = 'NONE';
        priority = 'NONE';
        timeFrame = 'NONE'; 
        
        filter();

    }
        
    // ********************************************************************************************************************************
    
    // ************************ DELETING ITEMS AND ACTIVITIES ****************************************************************

    public PageReference clearActivity() {
        activity = new Whiteboard_Item_Activity__c();
        editIndicator = false;
        filter();
        
        return null;
    }
    
    public PageReference clearItem() {
        Item = new Whiteboard_Item__c();
        editIndicator = false;
        filter();
        
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
                    filter();
                } else {
                    filter();
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
            filter();
        } else {
            filter();
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
            filter();
        } else {
            filter();
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
                    filter();
                } else {
                    filter();
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
            filter();
        } else {
            filter();
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
           filter();
        } else {
            filter();
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
            filter();
              } else {
            filter();
            
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
            filter();
        } else {
            filter();
        } 
        
        return;
    }

    public void deleteItem() {

        List<Whiteboard_Item__c> goners = [SELECT id, name from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];

            try {
                delete goners;
                if (indicator) {
                    filter();
                } else {
                    filter();
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
                    filter();
                } else {
                    filter();
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
        filter();

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
        filter();

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
        
        if(indicator)  {
           saveCompany();
            
        } else {
            savePersonal();
        }    
        filter();       
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
           filter();
        } else {
            saveActPersonal();
            filter();
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
        }                
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        editIndicator = false;
        return null;
    }   
    
    
    ///////****************************SIDE BAR METHODS**********************************************////////// 
    
    public List<SelectOption> getItemTask(){ //creates selection options for item v. activity filter bar
         List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('NONE', '--Type--'));
            options.add(new SelectOption('ITEM', 'Items'));
            options.add(new SelectOption('ACTIVITY','Activities'));
            return options;
    }

   public List<SelectOption> getItems() { //creates selection options for priority filter bar
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('NONE', '--Priority--'));
            options.add(new SelectOption('HIGH','High Priority'));
            options.add(new SelectOption('NOPRIORITY','No Priority'));
            return options;
    }
          
    public List<SelectOption> getItemsTwo() { //creates selection options for duedate filter bar
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

    public PageReference filter() { //called when any of the filters is clicked
        
                
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
        
        if(indicator == true){
           filterEverythingCompany(); 
        }else if(indicator == false){
         filterEverythingPersonal();
        }         
        return null;
    }

    
    public void filterEverythingCompany() { //main filter method for company whiteboard
        
        List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>(); //stores current items
        List<Whiteboard_Item__c> specialCase = new List<Whiteboard_Item__c>();
        List<Whiteboard_Item__c> tempList2 = new List<Whiteboard_Item__c>(); //stores completed items
        List<Whiteboard_Item__c> specialCase2 = new List<Whiteboard_Item__c>();
        
      if(searchValue == ''){ //if nothing is entered into the search box, then it is not account for in the SOQL statements  

        if(itemOrActivity == 'NONE' && priority == 'NONE' && timeframe == 'NONE'){

            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
        }else if(itemOrActivity == 'NONE' && priority == 'NONE' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
              
        }else if(itemOrActivity == 'ITEM' && priority == 'NONE' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx'
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ITEM' && priority == 'NONE' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate 
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NONE' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100]; 
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NONE' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'NONE' && priority == 'HIGH' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: true                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: true
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: true
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: false
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: true                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: true
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: true
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: false
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
       
        }else if(itemOrActivity == 'NONE' && priority == 'HIGH' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
                tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:true
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:true
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ITEM' && priority == 'HIGH' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx'
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c = true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c = true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ITEM' && priority == 'HIGH' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
           tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'HIGH' && timeframe == 'NONE'){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND High_Priority__c=: true
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND High_Priority__c=: true
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'HIGH' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
        
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: true
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: true
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'NONE' && priority == 'NOPRIORITY' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: false                            
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: false
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: false
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: true
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: false                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: false
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: false
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: true
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'NONE' && priority == 'NOPRIORITY' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ITEM' && priority == 'NOPRIORITY' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx'
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c = false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c = false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ITEM' && priority == 'NOPRIORITY' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
           tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NOPRIORITY' && timeframe == 'NONE'){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND High_Priority__c=: false
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND High_Priority__c=: false
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NOPRIORITY' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
        
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: false
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: false
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }
      }else if(searchValue != ''){//if something is entered into the search box, then it needs to be accounted for in the SOQL statements  
          
          String databaseSearch = '%' + searchValue + '%';
          
          if(itemOrActivity == 'NONE'&& priority == 'NONE' && timeframe == 'NONE'){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND(Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
              
              for(Whiteboard_Item__c i: specialCase){
                if( i.name.containsIgnoreCase(searchValue)|| i.Whiteboard_Item_Activities__r.size() > 0){
                 tempList.add(i);
                }else if(i.assignedTo__r.Name != null){
                    if(i.assignedTo__r.Name.containsIgnoreCase(searchValue)){
                           tempList.add(i);
                    }
                }
              }
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND(Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
              
               for(Whiteboard_Item__c i: specialCase2){
                if( i.name.containsIgnoreCase(searchValue)|| i.Whiteboard_Item_Activities__r.size() > 0){
                 tempList2.add(i);
                }else if(i.assignedTo__r.Name != null){
                    if(i.assignedTo__r.Name.containsIgnoreCase(searchValue)){
                           tempList2.add(i);
                    }
                }
              }
            
        }else if(itemOrActivity == 'NONE' && priority == 'NONE' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)    
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND (((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND (((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch)))) OR ((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))))
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                          
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)    
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND (((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND (((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch)))) OR ((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))))
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
              
        }else if(itemOrActivity == 'ITEM' && priority == 'NONE' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx'
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ITEM' && priority == 'NONE' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NONE' && timeframe == 'NONE'){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100]; 
                        
            for(Whiteboard_Item__c i: specialCase){
                if(i.Whiteboard_Item_Activities__r.size() > 0){
                    tempList.add(i);
                }
            }
            
            for(Whiteboard_Item__c i: specialCase2){
                if(i.Whiteboard_Item_Activities__r.size() > 0){
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NONE' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'NONE' && priority == 'HIGH' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND ((High_Priority__c =: false AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))OR (High_Priority__c =: true AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch)))
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                  
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND ((High_Priority__c =: false AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))OR (High_Priority__c =: true AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch)))
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
       
        }else if(itemOrActivity == 'NONE' && priority == 'HIGH' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND (((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) OR((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) ) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND(((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) OR((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) ) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ITEM' && priority == 'HIGH' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx'
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ITEM' && priority == 'HIGH' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
           tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'HIGH' && timeframe == 'NONE'){
                specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100]; 
                        
            for(Whiteboard_Item__c i: specialCase){
                if(i.Whiteboard_Item_Activities__r.size() > 0){
                    tempList.add(i);
                }
            }
            
            for(Whiteboard_Item__c i: specialCase2){
                if(i.Whiteboard_Item_Activities__r.size() > 0){
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'HIGH' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
        
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND (((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) OR((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) ) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND(((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) OR((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) ) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'NONE' && priority == 'NOPRIORITY' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND ((High_Priority__c =: false AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))OR (High_Priority__c =: true AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch)))
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                  
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND ((High_Priority__c =: false AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))OR (High_Priority__c =: true AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch)))
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
       
        }
        else if(itemOrActivity == 'NONE' && priority == 'NOPRIORITY' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
                        tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND (((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) OR((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) ) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND(((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) OR((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) ) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ITEM' && priority == 'NOPRIORITY' && timeframe == 'NONE'){
           tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx'
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ITEM' && priority == 'NOPRIORITY' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NOPRIORITY' && timeframe == 'NONE'){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: false AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE PersonalItem__c !=: indicator AND Completed__c =: true AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100]; 
                        
            for(Whiteboard_Item__c i: specialCase){
                if(i.Whiteboard_Item_Activities__r.size() > 0){
                    tempList.add(i);
                }
            }
            
            for(Whiteboard_Item__c i: specialCase2){
                if(i.Whiteboard_Item_Activities__r.size() > 0){
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NOPRIORITY' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                            WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: false 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
       
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE PersonalItem__c !=: indicator AND Completed__c =: true 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                          for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
            }
            
            
          
      }
        
        currentItems = tempList;
        completedItems = tempList2;
    }
    
public void filterEverythingPersonal() { //main filter method for personal whiteboard
        
        List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>(); //stores current items
        List<Whiteboard_Item__c> specialCase = new List<Whiteboard_Item__c>();
        List<Whiteboard_Item__c> tempList2 = new List<Whiteboard_Item__c>(); //stores completed items
        List<Whiteboard_Item__c> specialCase2 = new List<Whiteboard_Item__c>();
        
      if(searchValue == ''){ //if nothing is entered into the search box, then it is not account for in the SOQL statements             
        if(itemOrActivity == 'NONE' && priority == 'NONE' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
        }else if(itemOrActivity == 'NONE' && priority == 'NONE' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
              
        }else if(itemOrActivity == 'ITEM' && priority == 'NONE' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx'
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ITEM' && priority == 'NONE' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate 
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NONE' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100]; 
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NONE' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'NONE' && priority == 'HIGH' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: true                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: true
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: true
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: false
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: true                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: true
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: true
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: false
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
       
        }else if(itemOrActivity == 'NONE' && priority == 'HIGH' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
                tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:true
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:true
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ITEM' && priority == 'HIGH' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx'
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c = true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c = true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ITEM' && priority == 'HIGH' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
           tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'HIGH' && timeframe == 'NONE'){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c=: true
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c=: true
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'HIGH' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
        
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: true
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: true
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'NONE' && priority == 'NOPRIORITY' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: false                            
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: false
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: false
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: true
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: false                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: false
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: false
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: true
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'NONE' && priority == 'NOPRIORITY' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ITEM' && priority == 'NOPRIORITY' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx'
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c = false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c = false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ITEM' && priority == 'NOPRIORITY' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
           tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NOPRIORITY' && timeframe == 'NONE'){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c=: false
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c=: false
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NOPRIORITY' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
        
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: false
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =: false
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }
      }else if(searchValue != ''){//if something is entered into the search box, then it needs to be accounted for in the SOQL statements  
          
          String databaseSearch = '%' + searchValue + '%';
          
          if(itemOrActivity == 'NONE' && priority == 'NONE' && timeframe == 'NONE'){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND(Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
              
              for(Whiteboard_Item__c i: specialCase){
                if( i.name.containsIgnoreCase(searchValue)|| i.Whiteboard_Item_Activities__r.size() > 0){
                 tempList.add(i);
                }else if(i.assignedTo__r.Name != null){
                    if(i.assignedTo__r.Name.containsIgnoreCase(searchValue)){
                           tempList.add(i);
                    }
                }
              }
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND(Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
              
               for(Whiteboard_Item__c i: specialCase2){
                if( i.name.containsIgnoreCase(searchValue)|| i.Whiteboard_Item_Activities__r.size() > 0){
                 tempList2.add(i);
                }else if(i.assignedTo__r.Name != null){
                    if(i.assignedTo__r.Name.containsIgnoreCase(searchValue)){
                           tempList2.add(i);
                    }
                }
              }
            
        }else if(itemOrActivity == 'NONE' && priority == 'NONE' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)    
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND (((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND (((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch)))) OR ((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))))
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                          
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)    
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND (Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND (((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND (((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch)))) OR ((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))))
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
              
        }else if(itemOrActivity == 'ITEM' && priority == 'NONE' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx'
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ITEM' && priority == 'NONE' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NONE' && timeframe == 'NONE'){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100]; 
                        
            for(Whiteboard_Item__c i: specialCase){
                if(i.Whiteboard_Item_Activities__r.size() > 0){
                    tempList.add(i);
                }
            }
            
            for(Whiteboard_Item__c i: specialCase2){
                if(i.Whiteboard_Item_Activities__r.size() > 0){
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NONE' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'NONE' && priority == 'HIGH' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND ((High_Priority__c =: false AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))OR (High_Priority__c =: true AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch)))
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                  
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND ((High_Priority__c =: false AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))OR (High_Priority__c =: true AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch)))
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
       
        }else if(itemOrActivity == 'NONE' && priority == 'HIGH' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND (((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) OR((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) ) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND(((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) OR((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) ) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ITEM' && priority == 'HIGH' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx'
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ITEM' && priority == 'HIGH' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
           tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'HIGH' && timeframe == 'NONE'){
                specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100]; 
                        
            for(Whiteboard_Item__c i: specialCase){
                if(i.Whiteboard_Item_Activities__r.size() > 0){
                    tempList.add(i);
                }
            }
            
            for(Whiteboard_Item__c i: specialCase2){
                if(i.Whiteboard_Item_Activities__r.size() > 0){
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'HIGH' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
        
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND (((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) OR((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) ) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:true AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND(((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) OR((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) ) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'NONE' && priority == 'NOPRIORITY' && timeframe == 'NONE'){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND ((High_Priority__c =: false AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))OR (High_Priority__c =: true AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch)))
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                  
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND ((High_Priority__c =: false AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))OR (High_Priority__c =: true AND (NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch)))
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
       
        }
        else if(itemOrActivity == 'NONE' && priority == 'NOPRIORITY' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
                        tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND (((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) OR((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) ) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c, Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c, Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND(((Item_Due_Date__c =: null OR Item_Due_Date__c <: startDate OR Item_Due_Date__c >=: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) OR((Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate) AND ((NOT Name LIKE :databaseSearch) AND (NOT AssignedTo__r.Name LIKE :databaseSearch))) ) 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                   
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ITEM' && priority == 'NOPRIORITY' && timeframe == 'NONE'){
           tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx'
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ITEM' && priority == 'NOPRIORITY' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            tempList = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator  AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND High_Priority__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            tempList2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND id =: 'xxx12345xxx' //this id will never occur, it is a trick so that only items show up
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND High_Priority__c =: false AND Item_Due_Date__c >=: startDate AND Item_Due_Date__c <: endDate AND (Name LIKE :databaseSearch OR AssignedTo__r.Name LIKE :databaseSearch)
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NOPRIORITY' && timeframe == 'NONE'){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100];
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c, Completed_Date__c, Past_Due__c,
                        (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Past_Due__c, Completed_Date__c
                            FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND High_Priority__c =: false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)
                            ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                            LIMIT 30)
                        FROM Whiteboard_Item__c
                        WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true AND Activities__c >:0
                        ORDER BY High_Priority__c DESC, CreatedDate
                        LIMIT 100]; 
                        
            for(Whiteboard_Item__c i: specialCase){
                if(i.Whiteboard_Item_Activities__r.size() > 0){
                    tempList.add(i);
                }
            }
            
            for(Whiteboard_Item__c i: specialCase2){
                if(i.Whiteboard_Item_Activities__r.size() > 0){
                    tempList2.add(i);
                }
            }
        }else if(itemOrActivity == 'ACTIVITY' && priority == 'NOPRIORITY' && (timeframe == 'TODAY'||timeframe == 'TOMORROW'||timeframe == 'THISWEEK'||timeframe == 'NEXTWEEK'||timeframe == 'THISMONTH'||timeframe == 'NEXTMONTH'||timeframe == 'PAST')){
            specialCase = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                            WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                             
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: false 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
            
       
            
            specialCase2 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,Completed_Date__c,Past_Due__c,
                           (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name, Completed_Date__c,Past_Due__c
                              FROM Whiteboard_Item_Activities__r
                              WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Due_Date__c >=: startDate AND Due_Date__c <: endDate AND High_Priority__c =:false AND (Name LIKE :databaseSearch OR Description__c LIKE :databaseSearch OR actAssignedTo__r.Name LIKE :databaseSearch)                              
                              ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                              LIMIT 30)
                          FROM Whiteboard_Item__c
                          WHERE CreatedById =: UserInfo.getUserId() AND  PersonalItem__c !=: indicator AND Completed__c =: true 
                          ORDER BY High_Priority__c DESC, CreatedDate
                          LIMIT 100];
                          for (Whiteboard_Item__c i : specialCase) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList.add(i);
                }
            }
            for (Whiteboard_Item__c i : specialCase2) {
                if (i.Whiteboard_Item_Activities__r.size() > 0) {
                    tempList2.add(i);
                }
            }
            }
            
            
          
      }
        
        currentItems = tempList;
        completedItems = tempList2;
    }
    

    
    
    
    public List<Whiteboard_Item__c> getAllCompletedItems() {//gets all completed items on company or personal whiteboard
        List<Whiteboard_Item__c> allItems = new List<Whiteboard_Item__c>();

        if(indicator == true){//if you're on the company whiteboard
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
        }else if(indicator == false){//if you're on the personal whiteboard
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
    
    public PageReference clearSearch() {//called when 'clear' button is clicked, resets the search bar
        currentItems = getAllItems();
        completedItems = getAllCompletedItems();
        itemOrActivity = 'NONE';
        itemActBool = null;
        Priority = 'NONE';
        priorityBool = null;
        TimeFrame = 'NONE';
        startDate = null;
        endDate = null;
        o.closeDate = null;
        searchValue = '';
        
        
        return null;
    }
    
    //////end of sidebar methods//////////////////////////////// 

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
     @IsTest
     static void testGetItemTask()
    {
     WhiteboardController controller = new WhiteboardController();   
     List<SelectOption> testoptions = controller.getItemTask();
     system.assertEquals(3,testoptions.size());
    }
    
    @IsTest
     static void testGetItems()
    {
     WhiteboardController controller = new WhiteboardController();   
     List<SelectOption> testoptions = controller.getItems();
     system.assertEquals(3,testoptions.size());
    }
    
      @IsTest
     static void testGetItemsTwo()
    {
     WhiteboardController controller = new WhiteboardController();   
     List<SelectOption> testoptions = controller.getItemsTwo();
     system.assertEquals(8,testoptions.size());
    }       @IsTest
     static void testGetAllItems()
    {
        WhiteboardController controller = new WhiteboardController(); 
        Boolean indicator;
        
        Whiteboard_Item__c item = new Whiteboard_Item__c(Name = 'Item One', PersonalItem__c = false, Completed__c = false);
        controller.setItem(item);
        controller.save();      
        Whiteboard_Item__c item2 = new Whiteboard_Item__c(Name = 'Item Two', PersonalItem__c = false, Completed__c = false);
        controller.setItem(item2);
        controller.save();
        Whiteboard_Item__c item3 = new Whiteboard_Item__c(Name = 'Item Three', PersonalItem__c = true, Completed__c = false);
        controller.setItem(item3);
        controller.save();
        
        Controller.Indicator = true; //company whiteboard
        List<Whiteboard_Item__c> allItems = new List<Whiteboard_Item__c>();
        allItems = controller.getAllItems();        
        System.assertEquals(2, allItems.size());
        
        controller.Indicator = false;
        List<Whiteboard_Item__c> allItems2 = new List<Whiteboard_Item__c>();
        allItems2 = controller.getAllItems();       
        System.assertEquals(1, allItems2.size());
        
        
        Whiteboard_Item__c item4 = new Whiteboard_Item__c(Name = 'Item Three', PersonalItem__c = true, Completed__c = true);
        controller.setItem(item4);
        controller.save();
        
        controller.getPersonalItems();
        System.assertEquals(1, controller.currentItems.size());
        System.assertEquals('Personal Whiteboard', controller.currentWhiteboard);
        System.assertEquals(false, controller.indicator);
        System.assertEquals(1, controller.completedItems.size());
                
    }
    
           @IsTest
     static void testEditingItemsActs()
    {
        //clearActivity
        WhiteboardController controller = new WhiteboardController(); 
        controller.editIndicator = true;
        Controller.clearActivity();
        System.assertEquals(false, controller.editIndicator);
        
        //clearItem
        controller.editIndicator = true;
        Controller.clearItem();
        System.assertEquals(false, controller.editIndicator);
        
        //completeAct
        Whiteboard_Item__c item = new Whiteboard_Item__c(Name = 'Item One', PersonalItem__c = false, Completed__c = false);
        controller.setItem(item);
        controller.save();
        controller.setWhiteboardId(item.Id);
        Whiteboard_Item_Activity__c act = new Whiteboard_Item_Activity__c(Name = 'Act One');
        controller.setAct(act);        
        controller.saveAct();
        controller.saveActPersonal();
        ApexPages.currentpage().getParameters().put('ActId', act.Id);
        controller.completeAct();
        act = [SELECT Id, Name, Completed__c, CompletedBy__c, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')]; 
        System.assertEquals(act.Completed__c, true);
        System.assertEquals(act.Completed_Date__c, date.today());
        
        controller.indicator = false;
        Whiteboard_Item__c item2 = new Whiteboard_Item__c(Name = 'Item One', PersonalItem__c = true, Completed__c = false);
        controller.setItem(item2);
        controller.save();
        controller.setWhiteboardId(item2.Id);
        Whiteboard_Item_Activity__c act2 = new Whiteboard_Item_Activity__c(Name = 'Act Two');
        controller.setAct(act2);        
        controller.saveAct();
        controller.saveActPersonal();
        System.assertEquals(act2.Completed__c, false);
        ApexPages.currentpage().getParameters().put('ActId', act2.Id);
        controller.completeAct();
        act2 = [SELECT Id, Name, Completed__c, CompletedBy__c, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')]; 
        System.assertEquals(act2.Completed__c, true);
        System.assertEquals(act2.Completed_Date__c, date.today());
        
        //completeItem
        controller.indicator = true;
        ApexPages.currentpage().getParameters().put('ItemId', item.Id);
        System.assertEquals(false, item.completed__c);
        controller.completeItem();
        item = [SELECT id, name, Completed__c, Completedby__c, OwnerId
               from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
        System.assertEquals(true, item.completed__c);
        
        controller.indicator = false;
        ApexPages.currentpage().getParameters().put('ItemId', item2.Id);
        System.assertEquals(false, item2.completed__c);
        controller.completeItem();
        item2 = [SELECT id, name, Completed__c, Completedby__c, OwnerId
               from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
        System.assertEquals(true, item2.completed__c);  
		
		//uncomplete item
		controller.indicator = true;
		ApexPages.currentpage().getParameters().put('ItemId', item2.Id);
		System.assertEquals(true, item2.completed__c);
		controller.unCompleteItem();
        item2 = [SELECT id, name, Completed__c, Completedby__c, OwnerId
               from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
		System.assertEquals(false, item2.completed__c);
		
		controller.indicator = false;
		ApexPages.currentpage().getParameters().put('ItemId', item.Id);
		System.assertEquals(true, item.completed__c);
		controller.unCompleteItem();
        item = [SELECT id, name, Completed__c, Completedby__c, High_Priority__c, OwnerId
               from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
		System.assertEquals(false, item.completed__c);
		
		//uncomplete activity
              
		controller.indicator = true;
		ApexPages.currentpage().getParameters().put('ActId', act.Id);
		act = [SELECT Id, High_Priority__c, Name, Completed__c, CompletedBy__c, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')]; 
		System.assertEquals(true, act.completed__c);
		controller.uncompleteAct();
		act = [SELECT Id, High_Priority__c, Name, Completed__c, CompletedBy__c, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')]; 
		System.assertEquals(false, act.completed__c);
		
		controller.indicator = false;
		ApexPages.currentpage().getParameters().put('ActId', act2.Id);
		act2 = [SELECT Id, Name, Completed__c, CompletedBy__c, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')]; 
		System.assertEquals(true, act2.completed__c);
		controller.uncompleteAct();
		act2 = [SELECT Id, Name, Completed__c, CompletedBy__c, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')]; 
		System.assertEquals(false, act2.completed__c);
		
		//set priority
		controller.indicator = true;
		ApexPages.currentpage().getParameters().put('ItemId', item.Id);
		System.assertEquals(false, item.High_Priority__c);
		controller.setPriority();
        item = [SELECT id, name, Completed__c, High_Priority__c, Completedby__c, OwnerId
               from Whiteboard_Item__c where id = :item.id];
		System.assertEquals(true, item.High_Priority__c);
		controller.indicator = false;
		controller.setPriority();
		
		//unset priority
		controller.indicator = true;
		System.assertEquals(true, item.High_Priority__c);
		controller.unsetPriority();
		item = [SELECT id, name, Completed__c, High_Priority__c, Completedby__c, OwnerId
               from Whiteboard_Item__c where id = :item.id];
		System.assertEquals(false, item.High_Priority__c);
		controller.indicator = false;
		controller.unsetPriority();
		
		//set act priority
		controller.indicator = true;
		ApexPages.currentpage().getParameters().put('ActId', act.Id);
		System.assertEquals(false, act.High_Priority__c);
		controller.setActPriority();
        act = [SELECT Id, High_Priority__c, Name, Completed__c, CompletedBy__c, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')]; 
		System.assertEquals(true, act.High_Priority__c);
		controller.indicator = false;
		controller.setActPriority();
		
		//unset act priority
		controller.indicator = true;
		ApexPages.currentpage().getParameters().put('ActId', act.Id);
		System.assertEquals(true, act.High_Priority__c);
		controller.unSetActPriority();
        act = [SELECT Id, High_Priority__c, Name, Completed__c, CompletedBy__c, Completed_Date__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')]; 
		System.assertEquals(false, act.High_Priority__c);
		controller.indicator = false;
		controller.unSetActPriority();		
    }
    
        @IsTest
    static void testEdit()
    {
        WhiteboardController controller = new WhiteboardController();
        Whiteboard_Item__c item = new Whiteboard_Item__c(Name = 'Item One', PersonalItem__c = false, Completed__c = false);
        controller.setItem(item);
        controller.save();
        controller.setWhiteboardId(item.Id);
        Whiteboard_Item_Activity__c act = new Whiteboard_Item_Activity__c(Name = 'Act One');
        controller.setAct(act);        
        controller.saveAct();
        controller.saveActPersonal();
        ApexPages.currentpage().getParameters().put('ActId', act.Id);
        
		//edit item
		System.assertEquals(false, controller.editIndicator);
		controller.editItem();
		System.assertEquals(true, controller.editIndicator);
		
		//edit activity
		controller.editActivity();
		
		//reset
		controller.reset();
		System.assertEquals(false, controller.editIndicator);
		System.assertEquals(null, controller.assignedUser);
        
    }
	
	@IsTest
     static void testTimeFrameFilter()
    {
    WhiteboardController controller = new WhiteboardController();
        
	Whiteboard_Item__c item = new Whiteboard_Item__c(Name = 'Item One', PersonalItem__c = false, Completed__c = false);
    controller.setItem(item);
    controller.save();
	System.assertEquals(1, controller.currentItems.size());
        
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 System.assertEquals(0, controller.currentItems.size());
	 controller.TimeFrame = 'TOMORROW';
	 controller.filter();
	 System.assertEquals(0, controller.currentItems.size());
	 controller.TimeFrame = 'THISWEEK';
	 controller.filter();
	 System.assertEquals(0, controller.currentItems.size());
	 controller.TimeFrame = 'NEXTWEEK';
	 controller.filter();
	 System.assertEquals(0, controller.currentItems.size());
	 controller.TimeFrame = 'THISMONTH';
	 controller.filter();
	 System.assertEquals(0, controller.currentItems.size());
	 controller.TimeFrame = 'NEXTMONTH';
	 controller.filter();
	 System.assertEquals(0, controller.currentItems.size());
	 controller.TimeFrame = 'PAST';
	 controller.filter();
	 System.assertEquals(0, controller.currentItems.size());	 
	 
    }
	
	@IsTest
     static void testCompanyFilterWithoutSearch()
    {
    WhiteboardController controller = new WhiteboardController();
        
	Whiteboard_Item__c item = new Whiteboard_Item__c(Name = 'Item One', PersonalItem__c = false, Completed__c = false);
    controller.setItem(item);
    controller.save();
	System.assertEquals(1, controller.currentItems.size());
	controller.indicator = true;
     
	 controller.searchValue = '';
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
        
    }
	
	@IsTest
     static void testCompanyFilterWithSearch()
    {	
	WhiteboardController controller = new WhiteboardController();
	Whiteboard_Item__c item = new Whiteboard_Item__c(Name = 'Item One', PersonalItem__c = false, Completed__c = false);
    controller.setItem(item);
    controller.save();
	System.assertEquals(1, controller.currentItems.size());
	controller.indicator = true;
	
	
	 controller.searchValue = 'HELLO';
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 }
	 
	 	@IsTest
     static void testPersonalFilterWithoutSearch()
    {
    WhiteboardController controller = new WhiteboardController();
	controller.indicator = false;
       
	Whiteboard_Item__c item = new Whiteboard_Item__c(Name = 'Item One', PersonalItem__c = true, Completed__c = false);
    controller.setItem(item);
    controller.save();
	System.assertEquals(1, controller.currentItems.size());
	
	 controller.searchValue = '';
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
        
    }
	
	@IsTest
     static void testPersonalFilterWithSearch()
    {
	WhiteboardController controller = new WhiteboardController();
	controller.indicator = false;	
	Whiteboard_Item__c item = new Whiteboard_Item__c(Name = 'Item One', PersonalItem__c = true, Completed__c = false);
	controller.setItem(item);
    controller.save();
	System.assertEquals(1, controller.currentItems.size());

	
	 controller.searchValue = 'HELLO';
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NONE';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'HIGH';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'NONE';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ITEM';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'NONE';
	 controller.filter();
	 
	 controller.itemOrActivity = 'ACTIVITY';
	 controller.priority = 'NOPRIORITY';
     controller.TimeFrame = 'TODAY';
	 controller.filter();
	 }
		
}