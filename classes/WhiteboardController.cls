public with sharing class WhiteboardController { 
    
    public String WhiteboardId { get; set; }
    public String WhiteboardIdPersonal { get; set; }
    
    public List<User> AllUsers { get; set;}
    
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
    
    public String searchValue { get; set; }
    public String selectListValue { get; set; }
    public String selectListValueTwo { get; set; }
    public String itemTaskSelection { get ; set; }
    public Boolean itemActivity { get; set; }
    public String Priority { get; set; }
    public List<Whiteboard_Item__c> filteredList { get; set;}
    public List<Whiteboard_Item__c> preFilteredList { get; set;}
    Boolean result {get; set;}
    Boolean success{get; set;}   
    Opportunity o = new Opportunity();
    public Opportunity getProxyObject() { return o; }

    // ************************ SETTING UP CONTROLLER AND POPULATING LISTS ****************************************************************

    public WhiteboardController() {
        currentItems = new List<Whiteboard_Item__c>();
        trashItems = new List<Whiteboard_Item__c>();
        completedItems = new List<Whiteboard_Item__c>();

        Item = new Whiteboard_Item__c();
        activity = new Whiteboard_Item_Activity__c();
        getCompanyItems();
        indicator = true; 
        setBoardTitle(indicator);
        
        AllUsers = new List<User>();
        assignedUser = null;
    }
    
///////Side bar methods////////// 
  public PageReference searchItems(){//When you type in the search bar, this method is called
    
        String search = searchValue;
        List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
         if(indicator == true){
             filterItemActivity();
             filterPriority();
            filterDate();
       }if(indicator == false){
             filterItemActivity2();
             filterPriority2();
             filterDate2();
         }
 

     for(Whiteboard_Item__c WI: currentItems){
           success = false;
           for(Whiteboard_Item_Activity__c WA: WI.Whiteboard_Item_Activities__r){
               result = WA.name.containsIgnoreCase(searchValue); 
               if(result == true){
                  success = true;
               }
           }
                result = WI.name.containsIgnoreCase(searchValue);
                        if(result == true){
                             success = true;
                        }    
               if(success == true){
             tempList.add(WI);
            }
       }      
 currentItems = tempList;         
        return null;
    }
    
    
    public List<SelectOption> getItemTask(){ //creates selection options for item v. task select list
         List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('NONE', '--Type--'));
            options.add(new SelectOption('ITEM', 'Items'));
            options.add(new SelectOption('ACTIVITY','Activities'));
            return options;
    }
    
    public PageReference ItemTaskSelected(){

          if(indicator == true){
             filterItemActivity();
             filterPriority();
             filterDate();
         }
             if(indicator == false){
             filterItemActivity2();
             filterPriority2();
             filterDate2();
         }
    return null;
    }

   public List<SelectOption> getItems() { //creates selection options for priorities
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('NONE', '--Priority--'));
            options.add(new SelectOption('HIGH','High Priority'));
            options.add(new SelectOption('NOPRIORITY','No Priority'));
            return options;
    }
          
    public PageReference changeOrderBy(){ //method called when a filter is selected from the priorities selectList
        if(indicator == true){
             filterItemActivity();
             filterPriority();
             filterDate();
         }
          if(indicator == false){
             filterItemActivity2();
             filterPriority2();
             filterDate2();
         }
        
    return null;
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
   
   public PageReference changeOrderByTwo(){ //method called when a filter is selected from the date selectList
   
         if(indicator == true){
             filterItemActivity();
             filterPriority();
             filterDate();
         }
          if(indicator == false){
             filterItemActivity2();
             filterPriority2();
             filterDate2();
         } 
        
    return null;
   }
  ///////COMPANY WHITEBOARD SEARCH METHODS////////// 
public void filterItemActivity(){ //filters list by Item or Activity

 List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();

        currentItems = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
          tempList = currentItems;
         prefilteredList = currentItems;

}

public void filterPriority(){ //filters list by priority

       List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
       

 if(itemTaskSelection.equals('ITEM')){

      if(selectListValue.equals('HIGH')){
                for(Whiteboard_Item__c WI: currentItems){
                        if(WI.High_Priority__c == true){
                              tempList.add(WI);
                         }
              }
      } 
     else if(selectListValue.equals('NOPRIORITY')){

              for(Whiteboard_Item__c WI: currentItems){
                    if(WI.High_Priority__c == false){
                        tempList.add(WI);
                      }
              }
    }
  else if(selectListValue.equals('NONE')){

           for(Whiteboard_Item__c WI: preFilteredList){
                        tempList.add(WI);
                      
           }
    }
}

if(itemTaskSelection.equals('NONE')){

           if(selectListValue.equals('NONE')){
          tempList = preFilteredList;
          }

          if(selectListValue.equals('HIGH')){
           
            List<Whiteboard_Item__c> set1 = new List<Whiteboard_Item__c>();
            List<Whiteboard_Item__c> set2 = new List<Whiteboard_Item__c>();

                 set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

              For(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.high_priority__c == true){
                      x = true;
                   }
              }
              if(WI.High_Priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
        currentItems = tempList;
}
    else if(selectListValue.equals('NOPRIORITY')){

            List<Whiteboard_Item__c> set3 = new List<Whiteboard_Item__c>();
            List<Whiteboard_Item__c> set4 = new List<Whiteboard_Item__c>();

                         set3 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false AND High_Priority__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

                       set4 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false AND High_Priority__c =: true  AND Activities__c >:0
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
                     
                    set3.addAll(set4);
                      tempList = set3; 

    }
}
 if(itemTaskSelection.equals('ACTIVITY')){ //If Activities are selected
   if(selectListValue.equals('HIGH')){
               currentItems =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false  AND Activities__c >:0
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

        for(Whiteboard_Item__c WI: currentItems){
                 if(WI.Whiteboard_Item_Activities__r.size() != 0){
                    tempList.add(WI);
                 }
         }
    } 
else if(selectListValue.equals('NOPRIORITY')){
               currentItems =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

        for(Whiteboard_Item__c WI: currentItems){
                 if(WI.Whiteboard_Item_Activities__r.size() != 0){
                    tempList.add(WI);
                 }
         }
    }
 else if(selectListValue.equals('NONE')){



 for(Whiteboard_Item__c WI: currentItems){
          if(WI.Whiteboard_Item_Activities__r.size() != 0){
                    tempList.add(WI);
         }
}
} 
}
currentItems = tempList;
}

public void filterDate(){ //filters list by date due

List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
List<Whiteboard_Item__c> set1 = new List<Whiteboard_Item__c>();
List<Whiteboard_Item__c> set2 = new List<Whiteboard_Item__c>();
List<Whiteboard_Item__c> set3 = new List<Whiteboard_Item__c>();

if(itemTaskSelection.equals('NONE') && selectListValue.equals('NONE')){

       if(selectListValueTwo.equals('NONE')){

        }

      else if(selectListValueTwo.equals('TODAY')){
             set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND Due_Date__c =: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today()){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c == date.today()){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }

     else if(selectListValueTwo.equals('TOMORROW')){

    set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND Due_Date__c =: date.today().addDays(1)
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false AND Item_Due_Date__c =: date.today().addDays(1)
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today().addDays(1)){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c == date.today().addDays(1)){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }

    else if(selectListValueTwo.equals('THISWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND Due_Date__c >=: date.today().toStartofWeek() AND Due_Date__c <: date.today().toStartofWeek().addDays(7) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek() && WA.due_date__c < date.today().toStartofWeek().addDays(7)){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofWeek() && WI.Item_due_date__c < date.today().toStartofWeek().addDays(7)){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
   else if(selectListValueTwo.equals('NEXTWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND Due_Date__c >=:  date.today().toStartofWeek().addDays(7) AND Due_Date__c <: date.today().toStartofWeek().addDays(14) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek().addDays(7) && WA.due_date__c <  date.today().toStartofWeek().addDays(14)){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofWeek().addDays(7) && WI.Item_due_date__c <  date.today().toStartofWeek().addDays(14)){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
else if(selectListValueTwo.equals('THISMONTH')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND Due_Date__c >=:  date.today().toStartofMonth() AND Due_Date__c <: date.today().toStartofMonth().addMonths(1) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth() && WA.due_date__c < date.today().toStartofMonth().addMonths(1)){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofMonth() && WI.Item_due_date__c <  date.today().toStartofMonth().addMonths(1)){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }
else if(selectListValueTwo.equals('NEXTMONTH')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND Due_Date__c >=:  date.today().toStartofMonth().addMonths(1) AND Due_Date__c <: date.today().toStartofMonth().addMonths(2) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth().addMonths(1) && WA.due_date__c < date.today().toStartofMonth().addMonths(2)){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofMonth().addMonths(1) && WI.Item_due_date__c <  date.today().toStartofMonth().addMonths(2)){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList; 
     }
else if(selectListValueTwo.equals('PAST')){


       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r 
                          WHERE PersonalItem__c =: false AND Due_Date__c <: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){ 
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c < date.today()){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  < date.today()){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;            
}
}

if(itemTaskSelection.equals('NONE') && selectListValue.equals('HIGH')){

       if(selectListValueTwo.equals('NONE')){

        }

      else if(selectListValueTwo.equals('TODAY')){
             set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c =: date.today() AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
      
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today() && WA.high_priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c == date.today() && WI.high_priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
          currentItems = tempList;
           }
        }
     }

     else if(selectListValueTwo.equals('TOMORROW')){

    set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c =: date.today().addDays(1)  AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today().addDays(1) && WA.high_priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c == date.today().addDays(1) && WI.high_priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }

    else if(selectListValueTwo.equals('THISWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c >=: date.today().toStartofWeek() AND Due_Date__c <: date.today().toStartofWeek().addDays(7) AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek() && WA.due_date__c < date.today().toStartofWeek().addDays(7) && WA.high_priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofWeek() && WI.Item_due_date__c < date.today().toStartofWeek().addDays(7) && WI.high_priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
   else if(selectListValueTwo.equals('NEXTWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c >=:  date.today().toStartofWeek().addDays(7) AND Due_Date__c <: date.today().toStartofWeek().addDays(14) AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek().addDays(7) && WA.due_date__c <  date.today().toStartofWeek().addDays(14) && WA.high_priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofWeek().addDays(7) && WI.Item_due_date__c <  date.today().toStartofWeek().addDays(14) && WI.high_priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
else if(selectListValueTwo.equals('THISMONTH')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c >=:  date.today().toStartofMonth() AND Due_Date__c <: date.today().toStartofMonth().addMonths(1) AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth() && WA.due_date__c < date.today().toStartofMonth().addMonths(1) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofMonth() && WI.Item_due_date__c <  date.today().toStartofMonth().addMonths(1) && WI.High_Priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }
else if(selectListValueTwo.equals('NEXTMONTH')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c >=:  date.today().toStartofMonth().addMonths(1) AND Due_Date__c <: date.today().toStartofMonth().addMonths(2) AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth().addMonths(1) && WA.due_date__c < date.today().toStartofMonth().addMonths(2) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofMonth().addMonths(1) && WI.Item_due_date__c <  date.today().toStartofMonth().addMonths(2) && WI.High_Priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList; 
     }
else if(selectListValueTwo.equals('PAST')){


       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r 
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c <: date.today() AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){ 
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c < date.today() && WA.High_Priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  < date.today() && WI.High_Priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;            
}
}

if(itemTaskSelection.equals('NONE') && selectListValue.equals('NOPRIORITY')){

       if(selectListValueTwo.equals('NONE')){

        }

      else if(selectListValueTwo.equals('TODAY')){
             set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c =: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
      

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today() && WA.high_priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c == date.today() && WI.high_priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }

     else if(selectListValueTwo.equals('TOMORROW')){

    set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c =: date.today().addDays(1)  AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today().addDays(1) && WA.high_priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c == date.today().addDays(1) && WI.high_priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }

    else if(selectListValueTwo.equals('THISWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c >=: date.today().toStartofWeek() AND Due_Date__c <: date.today().toStartofWeek().addDays(7) AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek() && WA.due_date__c < date.today().toStartofWeek().addDays(7) && WA.high_priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofWeek() && WI.Item_due_date__c < date.today().toStartofWeek().addDays(7) && WI.high_priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
   else if(selectListValueTwo.equals('NEXTWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c >=:  date.today().toStartofWeek().addDays(7) AND Due_Date__c <: date.today().toStartofWeek().addDays(14) AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek().addDays(7) && WA.due_date__c <  date.today().toStartofWeek().addDays(14) && WA.high_priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofWeek().addDays(7) && WI.Item_due_date__c <  date.today().toStartofWeek().addDays(14) && WI.high_priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
else if(selectListValueTwo.equals('THISMONTH')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c >=:  date.today().toStartofMonth() AND Due_Date__c <: date.today().toStartofMonth().addMonths(1) AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth() && WA.due_date__c < date.today().toStartofMonth().addMonths(1) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofMonth() && WI.Item_due_date__c <  date.today().toStartofMonth().addMonths(1) && WI.High_Priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }
else if(selectListValueTwo.equals('NEXTMONTH')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c >=:  date.today().toStartofMonth().addMonths(1) AND Due_Date__c <: date.today().toStartofMonth().addMonths(2) AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth().addMonths(1) && WA.due_date__c < date.today().toStartofMonth().addMonths(2) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofMonth().addMonths(1) && WI.Item_due_date__c <  date.today().toStartofMonth().addMonths(2) && WI.High_Priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList; 
     }
else if(selectListValueTwo.equals('PAST')){


       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r 
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c <: date.today() AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){ 
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c < date.today() && WA.High_Priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  < date.today() && WI.High_Priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;            
}
}

//////
if(itemTaskSelection.equals('ITEM') && selectListValue.equals('HIGH')){

       if(selectListValueTwo.equals('NONE')){

        }
    
       if(selectListValueTwo.equals('TODAY')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c == date.today() && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }

       else if(selectListValueTwo.equals('TOMORROW')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c == date.today().addDays(1) && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }

      else if(selectListValueTwo.equals('THISWEEK')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofWeek() && WI.Item_Due_Date__c < date.today().toStartofWeek().addDays(7) && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
      else if(selectListValueTwo.equals('NEXTWEEK')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofWeek().addDays(7) && WI.Item_Due_Date__c < date.today().toStartofWeek().addDays(14) && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
      else if(selectListValueTwo.equals('THISMONTH')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofMonth() && WI.Item_Due_Date__c < date.today().toStartofMonth().addMonths(1) && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
     else if(selectListValueTwo.equals('NEXTMONTH')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofMonth().addMonths(1) && WI.Item_Due_Date__c < date.today().toStartofMonth().addMonths(2) && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
     else if(selectListValueTwo.equals('PAST')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c < date.today() && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
      currentItems = tempList;
     }
}

if(itemTaskSelection.equals('ITEM') && selectListValue.equals('NOPRIORITY')){

       if(selectListValueTwo.equals('NONE')){

        }
    
       if(selectListValueTwo.equals('TODAY')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c == date.today() && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }

       else if(selectListValueTwo.equals('TOMORROW')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c == date.today().addDays(1) && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }

      else if(selectListValueTwo.equals('THISWEEK')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofWeek() && WI.Item_Due_Date__c < date.today().toStartofWeek().addDays(7) && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
      else if(selectListValueTwo.equals('NEXTWEEK')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofWeek().addDays(7) && WI.Item_Due_Date__c < date.today().toStartofWeek().addDays(14) && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
      else if(selectListValueTwo.equals('THISMONTH')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofMonth() && WI.Item_Due_Date__c < date.today().toStartofMonth().addMonths(1) && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
     else if(selectListValueTwo.equals('NEXTMONTH')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofMonth().addMonths(1) && WI.Item_Due_Date__c < date.today().toStartofMonth().addMonths(2) && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
     else if(selectListValueTwo.equals('PAST')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c < date.today() && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
      currentItems = tempList;
     }
}

if(itemTaskSelection.equals('ITEM') && selectListValue.equals('NONE')){

       if(selectListValueTwo.equals('NONE')){

        }
    
       if(selectListValueTwo.equals('TODAY')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c == date.today()){
                         tempList.add(WI);
                   }
             }
    currentItems = tempList;
     }

       else if(selectListValueTwo.equals('TOMORROW')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c == date.today().addDays(1)){
                         tempList.add(WI);
                   }
             }
    currentItems = tempList;
     }

      else if(selectListValueTwo.equals('THISWEEK')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofWeek() && WI.Item_Due_Date__c < date.today().toStartofWeek().addDays(7)){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
      else if(selectListValueTwo.equals('NEXTWEEK')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofWeek().addDays(7) && WI.Item_Due_Date__c < date.today().toStartofWeek().addDays(14)){
                         tempList.add(WI);
                   }
             }
      currentItems = tempList;
     }
      else if(selectListValueTwo.equals('THISMONTH')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofMonth() && WI.Item_Due_Date__c < date.today().toStartofMonth().addMonths(1)){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
     else if(selectListValueTwo.equals('NEXTMONTH')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofMonth().addMonths(1) && WI.Item_Due_Date__c < date.today().toStartofMonth().addMonths(2)){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
     else if(selectListValueTwo.equals('PAST')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c < date.today()){
                         tempList.add(WI);
                   }
             }
       currentItems = tempList;
     }
}

if(itemTaskSelection.equals('ACTIVITY') && selectListValue.equals('NONE')){

       if(selectListValueTwo.equals('NONE')){

        }

      else if(selectListValueTwo.equals('TODAY')){
             set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND Due_Date__c =: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
           
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today()){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }

     else if(selectListValueTwo.equals('TOMORROW')){

    set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND Due_Date__c =: date.today().addDays(1)
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today().addDays(1)){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }

    else if(selectListValueTwo.equals('THISWEEK')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND Due_Date__c >=: date.today().toStartofWeek() AND Due_Date__c <: date.today().toStartofWeek().addDays(7) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek() && WA.due_date__c < date.today().toStartofWeek().addDays(7)){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
   else if(selectListValueTwo.equals('NEXTWEEK')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND Due_Date__c >=:  date.today().toStartofWeek().addDays(7) AND Due_Date__c <: date.today().toStartofWeek().addDays(14) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek().addDays(7) && WA.due_date__c <  date.today().toStartofWeek().addDays(14)){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
else if(selectListValueTwo.equals('THISMONTH')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND Due_Date__c >=:  date.today().toStartofMonth() AND Due_Date__c <: date.today().toStartofMonth().addMonths(1) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth() && WA.due_date__c < date.today().toStartofMonth().addMonths(1)){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }
else if(selectListValueTwo.equals('NEXTMONTH')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND Due_Date__c >=:  date.today().toStartofMonth().addMonths(1) AND Due_Date__c <: date.today().toStartofMonth().addMonths(2) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth().addMonths(1) && WA.due_date__c < date.today().toStartofMonth().addMonths(2)){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList; 
     }
else if(selectListValueTwo.equals('PAST')){


       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r 
                          WHERE PersonalItem__c =: false AND Due_Date__c <: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){ 
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c < date.today()){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;            
}
}

if(itemTaskSelection.equals('ACTIVITY') && selectListValue.equals('HIGH')){

       if(selectListValueTwo.equals('NONE')){

        }

      else if(selectListValueTwo.equals('TODAY')){
             set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c =: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       System.debug(' I get here 1');
           
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.High_Priority__c == true){
                    System.debug(' I get here 2');
           
                      x = true;
                   }
              }
           if(x == true){
           System.debug(' I get here 3');
           
           tempList.add(WI);
           }
        }
       System.debug(' I get here 4');           
       currentItems = tempList;
     }

     else if(selectListValueTwo.equals('TOMORROW')){

    set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c =: date.today().addDays(1)
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today().addDays(1) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }

    else if(selectListValueTwo.equals('THISWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c >=: date.today().toStartofWeek() AND Due_Date__c <: date.today().toStartofWeek().addDays(7) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek() && WA.due_date__c < date.today().toStartofWeek().addDays(7) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
   else if(selectListValueTwo.equals('NEXTWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c >=:  date.today().toStartofWeek().addDays(7) AND Due_Date__c <: date.today().toStartofWeek().addDays(14) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek().addDays(7) && WA.due_date__c <  date.today().toStartofWeek().addDays(14) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
else if(selectListValueTwo.equals('THISMONTH')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c >=:  date.today().toStartofMonth() AND Due_Date__c <: date.today().toStartofMonth().addMonths(1) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth() && WA.due_date__c < date.today().toStartofMonth().addMonths(1) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }
else if(selectListValueTwo.equals('NEXTMONTH')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c >=:  date.today().toStartofMonth().addMonths(1) AND Due_Date__c <: date.today().toStartofMonth().addMonths(2) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth().addMonths(1) && WA.due_date__c < date.today().toStartofMonth().addMonths(2) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList; 
     }
else if(selectListValueTwo.equals('PAST')){


       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r 
                          WHERE PersonalItem__c =: false AND High_Priority__c =:true AND Due_Date__c <: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){ 
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r ){
                   if(WA.due_date__c < date.today() && WA.High_Priority__c == true){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;            
}
}

if(itemTaskSelection.equals('ACTIVITY') && selectListValue.equals('NOPRIORITY')){

       if(selectListValueTwo.equals('NONE')){

        }

      else if(selectListValueTwo.equals('TODAY')){
             set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c =: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
           
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.High_Priority__c == false){           
                      x = true;
                   }
              }
           if(x == true){           
           tempList.add(WI);
           }
        }         
       currentItems = tempList;
     }
     else if(selectListValueTwo.equals('TOMORROW')){

    set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c =: date.today().addDays(1)
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today().addDays(1) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }

    else if(selectListValueTwo.equals('THISWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c >=: date.today().toStartofWeek() AND Due_Date__c <: date.today().toStartofWeek().addDays(7) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek() && WA.due_date__c < date.today().toStartofWeek().addDays(7) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
   else if(selectListValueTwo.equals('NEXTWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c >=:  date.today().toStartofWeek().addDays(7) AND Due_Date__c <: date.today().toStartofWeek().addDays(14) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek().addDays(7) && WA.due_date__c <  date.today().toStartofWeek().addDays(14) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
else if(selectListValueTwo.equals('THISMONTH')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c >=:  date.today().toStartofMonth() AND Due_Date__c <: date.today().toStartofMonth().addMonths(1) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth() && WA.due_date__c < date.today().toStartofMonth().addMonths(1) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }
else if(selectListValueTwo.equals('NEXTMONTH')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c >=:  date.today().toStartofMonth().addMonths(1) AND Due_Date__c <: date.today().toStartofMonth().addMonths(2) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth().addMonths(1) && WA.due_date__c < date.today().toStartofMonth().addMonths(2) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList; 
     }
else if(selectListValueTwo.equals('PAST')){


       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r 
                          WHERE PersonalItem__c =: false AND High_Priority__c =:false AND Due_Date__c <: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: false AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){ 
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r ){
                   if(WA.due_date__c < date.today() && WA.High_Priority__c == false){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;            
}
}

}
  ///////PERSONAL WHITEBOARD SEARCH METHODS//////////

public void filterItemActivity2(){ //filters list by Item or Activity

 List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();

        currentItems =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
          tempList = currentItems;
         prefilteredList = currentItems;
}

public void filterPriority2(){ //filters list by priority

       List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
       

 if(itemTaskSelection.equals('ITEM')){

      if(selectListValue.equals('HIGH')){
                for(Whiteboard_Item__c WI: currentItems){
                        if(WI.High_Priority__c == true){
                              tempList.add(WI);
                         }
              }
      } 
     else if(selectListValue.equals('NOPRIORITY')){

              for(Whiteboard_Item__c WI: currentItems){
                    if(WI.High_Priority__c == false){
                        tempList.add(WI);
                      }
              }
    }
  else if(selectListValue.equals('NONE')){

           for(Whiteboard_Item__c WI: preFilteredList){
                        tempList.add(WI);
                      
           }
    }
}

if(itemTaskSelection.equals('NONE')){

           if(selectListValue.equals('NONE')){
          tempList = preFilteredList;
          }

          if(selectListValue.equals('HIGH')){
           
            List<Whiteboard_Item__c> set1 = new List<Whiteboard_Item__c>();
            List<Whiteboard_Item__c> set2 = new List<Whiteboard_Item__c>();

                 set1 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

              For(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.high_priority__c == true){
                      x = true;
                   }
              }
              if(WI.High_Priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
        currentItems = tempList;
}
    else if(selectListValue.equals('NOPRIORITY')){

            List<Whiteboard_Item__c> set3 = new List<Whiteboard_Item__c>();
            List<Whiteboard_Item__c> set4 = new List<Whiteboard_Item__c>();

                         set3 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false AND High_Priority__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

                       set4 = [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false AND High_Priority__c =: true  AND Activities__c >:0
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
                     
                    set3.addAll(set4);
                      tempList = set3; 

    }
}
 if(itemTaskSelection.equals('ACTIVITY')){ //If Activities are selected
   if(selectListValue.equals('HIGH')){
               currentItems =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false  AND Activities__c >:0
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

        for(Whiteboard_Item__c WI: currentItems){
                 if(WI.Whiteboard_Item_Activities__r.size() != 0){
                    tempList.add(WI);
                 }
         }
    } 
else if(selectListValue.equals('NOPRIORITY')){
               currentItems =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

        for(Whiteboard_Item__c WI: currentItems){
                 if(WI.Whiteboard_Item_Activities__r.size() != 0){
                    tempList.add(WI);
                 }
         }
    }
 else if(selectListValue.equals('NONE')){



 for(Whiteboard_Item__c WI: currentItems){
          if(WI.Whiteboard_Item_Activities__r.size() != 0){
                    tempList.add(WI);
         }
}
} 
}
currentItems = tempList;
}

public void filterDate2(){ //filters list by date due

List<Whiteboard_Item__c> tempList = new List<Whiteboard_Item__c>();
List<Whiteboard_Item__c> set1 = new List<Whiteboard_Item__c>();
List<Whiteboard_Item__c> set2 = new List<Whiteboard_Item__c>();
List<Whiteboard_Item__c> set3 = new List<Whiteboard_Item__c>();

if(itemTaskSelection.equals('NONE') && selectListValue.equals('NONE')){

       if(selectListValueTwo.equals('NONE')){

        }

      else if(selectListValueTwo.equals('TODAY')){
             set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND Due_Date__c =: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today()){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c == date.today()){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }

     else if(selectListValueTwo.equals('TOMORROW')){

    set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND Due_Date__c =: date.today().addDays(1)
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false AND Item_Due_Date__c =: date.today().addDays(1)
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today().addDays(1)){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c == date.today().addDays(1)){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }

    else if(selectListValueTwo.equals('THISWEEK')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND Due_Date__c >=: date.today().toStartofWeek() AND Due_Date__c <: date.today().toStartofWeek().addDays(7) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek() && WA.due_date__c < date.today().toStartofWeek().addDays(7)){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofWeek() && WI.Item_due_date__c < date.today().toStartofWeek().addDays(7)){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
   else if(selectListValueTwo.equals('NEXTWEEK')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND Due_Date__c >=:  date.today().toStartofWeek().addDays(7) AND Due_Date__c <: date.today().toStartofWeek().addDays(14) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek().addDays(7) && WA.due_date__c <  date.today().toStartofWeek().addDays(14)){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofWeek().addDays(7) && WI.Item_due_date__c <  date.today().toStartofWeek().addDays(14)){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
else if(selectListValueTwo.equals('THISMONTH')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND Due_Date__c >=:  date.today().toStartofMonth() AND Due_Date__c <: date.today().toStartofMonth().addMonths(1) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth() && WA.due_date__c < date.today().toStartofMonth().addMonths(1)){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofMonth() && WI.Item_due_date__c <  date.today().toStartofMonth().addMonths(1)){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }
else if(selectListValueTwo.equals('NEXTMONTH')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND Due_Date__c >=:  date.today().toStartofMonth().addMonths(1) AND Due_Date__c <: date.today().toStartofMonth().addMonths(2) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth().addMonths(1) && WA.due_date__c < date.today().toStartofMonth().addMonths(2)){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofMonth().addMonths(1) && WI.Item_due_date__c <  date.today().toStartofMonth().addMonths(2)){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList; 
     }
else if(selectListValueTwo.equals('PAST')){


       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r 
                          WHERE PersonalItem__c =: true AND Due_Date__c <: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){ 
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c < date.today()){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  < date.today()){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;            
}
}

if(itemTaskSelection.equals('NONE') && selectListValue.equals('HIGH')){

       if(selectListValueTwo.equals('NONE')){

        }

      else if(selectListValueTwo.equals('TODAY')){
             set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c =: date.today() AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
      
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today() && WA.high_priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c == date.today() && WI.high_priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
          currentItems = tempList;
           }
        }
     }

     else if(selectListValueTwo.equals('TOMORROW')){

    set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c =: date.today().addDays(1)  AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today().addDays(1) && WA.high_priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c == date.today().addDays(1) && WI.high_priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }

    else if(selectListValueTwo.equals('THISWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c >=: date.today().toStartofWeek() AND Due_Date__c <: date.today().toStartofWeek().addDays(7) AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek() && WA.due_date__c < date.today().toStartofWeek().addDays(7) && WA.high_priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofWeek() && WI.Item_due_date__c < date.today().toStartofWeek().addDays(7) && WI.high_priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
   else if(selectListValueTwo.equals('NEXTWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c >=:  date.today().toStartofWeek().addDays(7) AND Due_Date__c <: date.today().toStartofWeek().addDays(14) AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek().addDays(7) && WA.due_date__c <  date.today().toStartofWeek().addDays(14) && WA.high_priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofWeek().addDays(7) && WI.Item_due_date__c <  date.today().toStartofWeek().addDays(14) && WI.high_priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
else if(selectListValueTwo.equals('THISMONTH')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c >=:  date.today().toStartofMonth() AND Due_Date__c <: date.today().toStartofMonth().addMonths(1) AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth() && WA.due_date__c < date.today().toStartofMonth().addMonths(1) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofMonth() && WI.Item_due_date__c <  date.today().toStartofMonth().addMonths(1) && WI.High_Priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }
else if(selectListValueTwo.equals('NEXTMONTH')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c >=:  date.today().toStartofMonth().addMonths(1) AND Due_Date__c <: date.today().toStartofMonth().addMonths(2) AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth().addMonths(1) && WA.due_date__c < date.today().toStartofMonth().addMonths(2) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofMonth().addMonths(1) && WI.Item_due_date__c <  date.today().toStartofMonth().addMonths(2) && WI.High_Priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList; 
     }
else if(selectListValueTwo.equals('PAST')){


       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r 
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c <: date.today() AND High_Priority__c =: true
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){ 
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c < date.today() && WA.High_Priority__c == true){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  < date.today() && WI.High_Priority__c == true){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;            
}
}

if(itemTaskSelection.equals('NONE') && selectListValue.equals('NOPRIORITY')){

       if(selectListValueTwo.equals('NONE')){

        }

      else if(selectListValueTwo.equals('TODAY')){
             set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c =: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
      

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today() && WA.high_priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c == date.today() && WI.high_priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }

     else if(selectListValueTwo.equals('TOMORROW')){

    set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c =: date.today().addDays(1)  AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today().addDays(1) && WA.high_priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c == date.today().addDays(1) && WI.high_priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }

    else if(selectListValueTwo.equals('THISWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c >=: date.today().toStartofWeek() AND Due_Date__c <: date.today().toStartofWeek().addDays(7) AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek() && WA.due_date__c < date.today().toStartofWeek().addDays(7) && WA.high_priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofWeek() && WI.Item_due_date__c < date.today().toStartofWeek().addDays(7) && WI.high_priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
   else if(selectListValueTwo.equals('NEXTWEEK')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c >=:  date.today().toStartofWeek().addDays(7) AND Due_Date__c <: date.today().toStartofWeek().addDays(14) AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek().addDays(7) && WA.due_date__c <  date.today().toStartofWeek().addDays(14) && WA.high_priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofWeek().addDays(7) && WI.Item_due_date__c <  date.today().toStartofWeek().addDays(14) && WI.high_priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
else if(selectListValueTwo.equals('THISMONTH')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c >=:  date.today().toStartofMonth() AND Due_Date__c <: date.today().toStartofMonth().addMonths(1) AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth() && WA.due_date__c < date.today().toStartofMonth().addMonths(1) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofMonth() && WI.Item_due_date__c <  date.today().toStartofMonth().addMonths(1) && WI.High_Priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }
else if(selectListValueTwo.equals('NEXTMONTH')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c >=:  date.today().toStartofMonth().addMonths(1) AND Due_Date__c <: date.today().toStartofMonth().addMonths(2) AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth().addMonths(1) && WA.due_date__c < date.today().toStartofMonth().addMonths(2) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  >= date.today().toStartofMonth().addMonths(1) && WI.Item_due_date__c <  date.today().toStartofMonth().addMonths(2) && WI.High_Priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList; 
     }
else if(selectListValueTwo.equals('PAST')){


       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r 
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c <: date.today() AND High_Priority__c =: false
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){ 
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c < date.today() && WA.High_Priority__c == false){
                      x = true;
                   }
              }
              if(WI.Item_Due_Date__c  < date.today() && WI.High_Priority__c == false){
               x = true;
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;            
}
}

//////
if(itemTaskSelection.equals('ITEM') && selectListValue.equals('HIGH')){

       if(selectListValueTwo.equals('NONE')){

        }
    
       if(selectListValueTwo.equals('TODAY')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c == date.today() && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }

       else if(selectListValueTwo.equals('TOMORROW')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c == date.today().addDays(1) && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }

      else if(selectListValueTwo.equals('THISWEEK')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofWeek() && WI.Item_Due_Date__c < date.today().toStartofWeek().addDays(7) && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
      else if(selectListValueTwo.equals('NEXTWEEK')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofWeek().addDays(7) && WI.Item_Due_Date__c < date.today().toStartofWeek().addDays(14) && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
      else if(selectListValueTwo.equals('THISMONTH')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofMonth() && WI.Item_Due_Date__c < date.today().toStartofMonth().addMonths(1) && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
     else if(selectListValueTwo.equals('NEXTMONTH')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofMonth().addMonths(1) && WI.Item_Due_Date__c < date.today().toStartofMonth().addMonths(2) && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
     else if(selectListValueTwo.equals('PAST')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c < date.today() && WI.High_Priority__c == true){
                         tempList.add(WI);
                   }
             }
      currentItems = tempList;
     }
}

if(itemTaskSelection.equals('ITEM') && selectListValue.equals('NOPRIORITY')){

       if(selectListValueTwo.equals('NONE')){

        }
    
       if(selectListValueTwo.equals('TODAY')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c == date.today() && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }

       else if(selectListValueTwo.equals('TOMORROW')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c == date.today().addDays(1) && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }

      else if(selectListValueTwo.equals('THISWEEK')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofWeek() && WI.Item_Due_Date__c < date.today().toStartofWeek().addDays(7) && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
      else if(selectListValueTwo.equals('NEXTWEEK')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofWeek().addDays(7) && WI.Item_Due_Date__c < date.today().toStartofWeek().addDays(14) && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
      else if(selectListValueTwo.equals('THISMONTH')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofMonth() && WI.Item_Due_Date__c < date.today().toStartofMonth().addMonths(1) && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
     else if(selectListValueTwo.equals('NEXTMONTH')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofMonth().addMonths(1) && WI.Item_Due_Date__c < date.today().toStartofMonth().addMonths(2) && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
     else if(selectListValueTwo.equals('PAST')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c < date.today() && WI.High_Priority__c == false){
                         tempList.add(WI);
                   }
             }
      currentItems = tempList;
     }
}

if(itemTaskSelection.equals('ITEM') && selectListValue.equals('NONE')){

       if(selectListValueTwo.equals('NONE')){

        }
    
       if(selectListValueTwo.equals('TODAY')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c == date.today()){
                         tempList.add(WI);
                   }
             }
    currentItems = tempList;
     }

       else if(selectListValueTwo.equals('TOMORROW')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c == date.today().addDays(1)){
                         tempList.add(WI);
                   }
             }
    currentItems = tempList;
     }

      else if(selectListValueTwo.equals('THISWEEK')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofWeek() && WI.Item_Due_Date__c < date.today().toStartofWeek().addDays(7)){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
      else if(selectListValueTwo.equals('NEXTWEEK')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofWeek().addDays(7) && WI.Item_Due_Date__c < date.today().toStartofWeek().addDays(14)){
                         tempList.add(WI);
                   }
             }
      currentItems = tempList;
     }
      else if(selectListValueTwo.equals('THISMONTH')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofMonth() && WI.Item_Due_Date__c < date.today().toStartofMonth().addMonths(1)){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
     else if(selectListValueTwo.equals('NEXTMONTH')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c >= date.today().toStartofMonth().addMonths(1) && WI.Item_Due_Date__c < date.today().toStartofMonth().addMonths(2)){
                         tempList.add(WI);
                   }
             }
     currentItems = tempList;
     }
     else if(selectListValueTwo.equals('PAST')){
            for(Whiteboard_Item__c WI: prefilteredList){
                  if(WI.Item_Due_Date__c < date.today()){
                         tempList.add(WI);
                   }
             }
       currentItems = tempList;
     }
}

if(itemTaskSelection.equals('ACTIVITY') && selectListValue.equals('NONE')){

       if(selectListValueTwo.equals('NONE')){

        }

      else if(selectListValueTwo.equals('TODAY')){
             set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND Due_Date__c =: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
           
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today()){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }

     else if(selectListValueTwo.equals('TOMORROW')){

    set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND Due_Date__c =: date.today().addDays(1)
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today().addDays(1)){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }

    else if(selectListValueTwo.equals('THISWEEK')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND Due_Date__c >=: date.today().toStartofWeek() AND Due_Date__c <: date.today().toStartofWeek().addDays(7) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek() && WA.due_date__c < date.today().toStartofWeek().addDays(7)){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
   else if(selectListValueTwo.equals('NEXTWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND Due_Date__c >=:  date.today().toStartofWeek().addDays(7) AND Due_Date__c <: date.today().toStartofWeek().addDays(14) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek().addDays(7) && WA.due_date__c <  date.today().toStartofWeek().addDays(14)){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
else if(selectListValueTwo.equals('THISMONTH')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND Due_Date__c >=:  date.today().toStartofMonth() AND Due_Date__c <: date.today().toStartofMonth().addMonths(1) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth() && WA.due_date__c < date.today().toStartofMonth().addMonths(1)){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }
else if(selectListValueTwo.equals('NEXTMONTH')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND Due_Date__c >=:  date.today().toStartofMonth().addMonths(1) AND Due_Date__c <: date.today().toStartofMonth().addMonths(2) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth().addMonths(1) && WA.due_date__c < date.today().toStartofMonth().addMonths(2)){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList; 
     }
else if(selectListValueTwo.equals('PAST')){


       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r 
                          WHERE PersonalItem__c =: true AND Due_Date__c <: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){ 
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c < date.today()){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;            
}
}

if(itemTaskSelection.equals('ACTIVITY') && selectListValue.equals('HIGH')){

       if(selectListValueTwo.equals('NONE')){

        }

      else if(selectListValueTwo.equals('TODAY')){
             set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c =: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       System.debug(' I get here 1');
           
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.High_Priority__c == true){
                    System.debug(' I get here 2');
           
                      x = true;
                   }
              }
           if(x == true){
           System.debug(' I get here 3');
           
           tempList.add(WI);
           }
        }
       System.debug(' I get here 4');           
       currentItems = tempList;
     }

     else if(selectListValueTwo.equals('TOMORROW')){

    set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c =: date.today().addDays(1)
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today().addDays(1) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }

    else if(selectListValueTwo.equals('THISWEEK')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c >=: date.today().toStartofWeek() AND Due_Date__c <: date.today().toStartofWeek().addDays(7) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek() && WA.due_date__c < date.today().toStartofWeek().addDays(7) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
   else if(selectListValueTwo.equals('NEXTWEEK')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c >=:  date.today().toStartofWeek().addDays(7) AND Due_Date__c <: date.today().toStartofWeek().addDays(14) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek().addDays(7) && WA.due_date__c <  date.today().toStartofWeek().addDays(14) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
else if(selectListValueTwo.equals('THISMONTH')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c >=:  date.today().toStartofMonth() AND Due_Date__c <: date.today().toStartofMonth().addMonths(1) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth() && WA.due_date__c < date.today().toStartofMonth().addMonths(1) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }
else if(selectListValueTwo.equals('NEXTMONTH')){

       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c >=:  date.today().toStartofMonth().addMonths(1) AND Due_Date__c <: date.today().toStartofMonth().addMonths(2) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth().addMonths(1) && WA.due_date__c < date.today().toStartofMonth().addMonths(2) && WA.High_Priority__c == true){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList; 
     }
else if(selectListValueTwo.equals('PAST')){


       set1 =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r 
                          WHERE PersonalItem__c =: true AND High_Priority__c =:true AND Due_Date__c <: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){ 
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r ){
                   if(WA.due_date__c < date.today() && WA.High_Priority__c == true){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;            
}
}

if(itemTaskSelection.equals('ACTIVITY') && selectListValue.equals('NOPRIORITY')){

       if(selectListValueTwo.equals('NONE')){

        }

      else if(selectListValueTwo.equals('TODAY')){
             set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c =: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
           
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.High_Priority__c == false){           
                      x = true;
                   }
              }
           if(x == true){           
           tempList.add(WI);
           }
        }         
       currentItems = tempList;
     }
     else if(selectListValueTwo.equals('TOMORROW')){

    set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c =: date.today().addDays(1)
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: true AND Completed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];

         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c == date.today().addDays(1) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }

    else if(selectListValueTwo.equals('THISWEEK')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c >=: date.today().toStartofWeek() AND Due_Date__c <: date.today().toStartofWeek().addDays(7) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek() && WA.due_date__c < date.today().toStartofWeek().addDays(7) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
   else if(selectListValueTwo.equals('NEXTWEEK')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c >=:  date.today().toStartofWeek().addDays(7) AND Due_Date__c <: date.today().toStartofWeek().addDays(14) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofWeek().addDays(7) && WA.due_date__c <  date.today().toStartofWeek().addDays(14) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;

     }
else if(selectListValueTwo.equals('THISMONTH')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c >=:  date.today().toStartofMonth() AND Due_Date__c <: date.today().toStartofMonth().addMonths(1) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth() && WA.due_date__c < date.today().toStartofMonth().addMonths(1) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;
     }
else if(selectListValueTwo.equals('NEXTMONTH')){

       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name 
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c >=:  date.today().toStartofMonth().addMonths(1) AND Due_Date__c <: date.today().toStartofMonth().addMonths(2) 
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r){
                   if(WA.due_date__c >= date.today().toStartofMonth().addMonths(1) && WA.due_date__c < date.today().toStartofMonth().addMonths(2) && WA.High_Priority__c == false){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList; 
     }
else if(selectListValueTwo.equals('PAST')){


       set1 =   [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
                          FROM Whiteboard_Item_Activities__r 
                          WHERE PersonalItem__c =: true AND High_Priority__c =:false AND Due_Date__c <: date.today()
                          ORDER BY Completed__c, High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c 
                      WHERE PersonalItem__c =: true AND Completed__c =: false 
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
       
         for(Whiteboard_Item__c WI: set1){ 
              Boolean x = false;
              for(Whiteboard_Item_Activity__c WA: WI.whiteboard_item_activities__r ){
                   if(WA.due_date__c < date.today() && WA.High_Priority__c == false){
                      x = true;
                   }
              }
           if(x == true){
           tempList.add(WI);
           }
        }
       currentItems = tempList;            
}
}

}
//////end of sidebar methods////////////////////////////////    
 
    
    public List<SelectOption> getUserList() {
        AllUsers = [Select Name, LastName, Id, FirstName, Username, Email From User];            
        List<SelectOption> UserList = new List<SelectOption>();
        UserList.add(new SelectOption('', 'None'));
        
        for(User temp : AllUsers)
        {
            UserList.add(new SelectOption(temp.Id, temp.Name));
        }
        
        return UserList;
    }
    
    public void setBoardTitle(Boolean board) {
        if (board) {     
            companyName = [SELECT Name FROM Organization LIMIT 1].Name;
            if (companyName == null || companyName == '') {
                currentWhiteboard = 'Company Whiteboard';
             } else {
                currentWhiteboard = companyName + ' Whiteboard';    
             }
        } else {
            userName = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()].Name;
            if (userName == null || userName == '') {
                currentWhiteboard = 'Personal Whiteboard';
            } else {
                currentWhiteboard = userName + '\'s Whiteboard';
            }
        }
    }
    
    public void getCompanyItems() {
        //currentWhiteboard = 'Company Whiteboard';
        currentItems =  [SELECT Name, Id, Item_Due_Date__c, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name, Activities__c,
                       (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id, Completedby__c, CompletedBy__r.Name, High_Priority__c, actAssignedTo__c, actAssignedTo__r.Name
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

        itemTaskSelection = 'None';
        selectListValue = 'None';
        selectListValueTwo = 'NONE';
        
        getCompanyCompleted();
    }              

    public void getCompanyCompleted() {  
        completedItems = [SELECT Name, Id, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c, OwnerId, assignedTo__c, assignedTo__r.Name,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c,  actAssignedTo__c, actAssignedTo__r.Name
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
        currentItems = [SELECT Name, Id, Trashed__c, Completed__c, High_Priority__c, Completedby__c, CompletedBy__r.Name, OwnerId, assignedTo__c, assignedTo__r.Name,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Id, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c,  actAssignedTo__c, actAssignedTo__r.Name
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

       itemTaskSelection = 'None';
       selectListValue = 'None';
       selectListValueTwo = 'NONE';
    }
    
    public void getPersonalCompleted() {  
                      
        completedItems = [SELECT Name, Id, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c, OwnerId, assignedTo__c, assignedTo__r.Name,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Completedby__c, CompletedBy__r.Name, High_Priority__c,  actAssignedTo__c, actAssignedTo__r.Name
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

    public void completeAct() {
        List<Whiteboard_Item_Activity__c> completed = [SELECT Id, Name, Completed__c, CompletedBy__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        for (Whiteboard_Item_Activity__c act : completed) {
            act.Completed__c = true;   
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
                                                     (SELECT Name, Id, Completedby__c, CompletedBy__r.Name, Completed__c
                                                      FROM Whiteboard_Item_Activities__r
                                                      WHERE PersonalItem__c =: false 
                                                      LIMIT 30)
                                                    from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
        
        Id userid = UserInfo.getUserId();
        //Check the "Completed" checkbox on that item
        for(Whiteboard_Item__c item : itemsToComplete) {
            item.Completed__c = true;
            item.CompletedBy__c = userid;
            
            for (Whiteboard_Item_Activity__c act : item.Whiteboard_Item_Activities__r) {
                if (act.Completed__c == false) {
                    act.CompletedBy__c = userid;
                    update act;
                }
            }
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
                                                        (SELECT Name, Id, Completedby__c, CompletedBy__r.Name, Completed__c
                                                          FROM Whiteboard_Item_Activities__r
                                                          WHERE PersonalItem__c =: false 
                                                          LIMIT 30)
                                                      from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
        
        //UnCheck the "Completed" checkbox on that item
        for(Whiteboard_Item__c item : itemsToUnComplete) {
            item.Completed__c = false;
            item.Completedby__c = null;
            
            for (Whiteboard_Item_Activity__c act : item.Whiteboard_Item_Activities__r) {
                if (act.Completed__c == false)
                    act.CompletedBy__c = null;
            }
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
        List<Whiteboard_Item_Activity__c> completed = [SELECT Id, Name, Completed__c, CompletedBy__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        for (Whiteboard_Item_Activity__c act : completed) {
            act.Completed__c = false;  
            act.CompletedBy__c = null;
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
        List<Whiteboard_Item_Activity__c> actToGivePriority = [SELECT Id, Name, High_Priority__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        
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
        List<Whiteboard_Item_Activity__c> actToGivePriority = [SELECT Id, Name, High_Priority__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        
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
        List<Whiteboard_Item_Activity__c> goners = [SELECT Id, Name from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
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
    
    
    
    // ********************************************************************************************************************************
    
    public Whiteboard_Item__c[] getWhiteboard() {

        return [SELECT Name, Id,
                     (SELECT Name, Due_Date__c, Description__c, Id
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
                         (SELECT Name, Due_Date__c, Description__c, Id
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
            insert Item;
            Item = new Whiteboard_Item__c();
            

            getCompanyItems();         
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
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
        activity.Whiteboard_Item__c = WhiteboardId;
        show = 'Id: ' + activity.Whiteboard_Item__c + ', Name: ' + activity.Name + ', Description: ' + activity.Description__c;
        if (activity.Name == '' || activity.Name == null) {
            return null;   
        }
        try {
            insert activity;
            activity = new Whiteboard_Item_Activity__c();
            getCompanyItems();
        }                
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    public void savePersonal() {

        try
        {
            Item.PersonalItem__c = true;
            insert Item;
            Item = new Whiteboard_Item__c();
          
            getPersonalItems();         
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return;
    }
    
    public PageReference saveActPersonal() {
        
        activity.Whiteboard_Item__c = WhiteboardId;
        show = 'Id: ' + activity.Whiteboard_Item__c + ', Name: ' + activity.Name + ', Description: ' + activity.Description__c;
        if (activity.Name == '' || activity.Name == null) {
            return null;   
        }
        try {
            activity.PersonalItem__c = true;
        
            insert activity;
            activity = new Whiteboard_Item_Activity__c();
            //getCompanyItems();
            getPersonalItems();
        }                
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
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
        
        //Whiteboard_Item__c[] w = [SELECT Name, Id, (select Name, Due_Date__c, Description__c from Whiteboard_Item_Activities__r order by CreatedDate)
         //                         from Whiteboard_Item__c order by CreatedDate];
        //System.assertEquals(w[0].Name, controller.getWhiteboard()[0].Name);
        
        //System.assertEquals(null, controller.save());
        
        //System.assertEquals(null, controller.saveaCT());
    }
}