public with sharing class WhiteboardController { 
    
    public String WhiteboardId { get; set; }
    public String WhiteboardIdPersonal { get; set; }
    
    public Whiteboard_Item_Activity__c activity { get; set; }
    public Whiteboard_Item__c Item { get; set; }
    
    public List<Whiteboard_Item__c> currentItems { get; set;}
    public List<Whiteboard_Item__c> trashItems { get; set; }
    public List<Whiteboard_Item__c> completedItems { get; set; }
    
    public String currentWhiteboard { get; set; }
    public String currentWhiteboardTrash { get; set; }
    public Boolean indicator { get; set; }  // true if company, false if personal
    public String show { get; set; }

    // ************************ SETTING UP CONTROLLER AND POPULATING LISTS ****************************************************************

    public WhiteboardController() {
        currentItems = new List<Whiteboard_Item__c>();
        trashItems = new List<Whiteboard_Item__c>();
        completedItems = new List<Whiteboard_Item__c>();
        
        currentWhiteboard = 'Company Whiteboard';
        Item = new Whiteboard_Item__c();
        activity = new Whiteboard_Item_Activity__c();
        getCompanyItems();
        indicator = true; 
    }
    
    public void getCompanyItems() {
        //currentWhiteboard = 'Company Whiteboard';
        currentItems = [SELECT Name, Id, Trashed__c, Completed__c, High_Priority__c,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c, Id
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false 
                          ORDER BY High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Trashed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
        indicator = true;
        getCompanyTrash();
        getCompanyCompleted();
        
        currentWhiteboard = 'Company Whiteboard';
        currentWhiteboardTrash = 'Company Whiteboard Trash';
    }              
          
    public void getCompanyTrash() { 
        trashItems = [SELECT Name, Id, Trashed__c, Completed__c,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Id, Completed__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE PersonalItem__c =: false 
                          ORDER BY CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE PersonalItem__c =: false AND Trashed__c =: true
                      ORDER BY CreatedDate
                      LIMIT 100];   
    }
    
    public void getCompanyCompleted() {  
        completedItems = [SELECT Name, Id, Completed__c,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c
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
        currentItems = [SELECT Name, Id, Trashed__c, Completed__c, High_Priority__c,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Id, Completed__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true
                          ORDER BY High_Priority__c DESC, CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true AND Trashed__c =: false
                      ORDER BY High_Priority__c DESC, CreatedDate
                      LIMIT 100];
        indicator = false;
        getPersonalTrash();
        getPersonalCompleted();
    }
    
    public void getPersonalTrash() {
        trashItems = [SELECT Name, Id, Trashed__c, Completed__c,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true
                          ORDER BY CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true AND Trashed__c =: true
                      ORDER BY CreatedDate
                      LIMIT 100];
    }
    
    public void getPersonalCompleted() {  
                      
        completedItems = [SELECT Name, Id, Completed__c,
                         (SELECT Name, Due_Date__c, Description__c, Trashed__c, Completed__c
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
        List<Whiteboard_Item_Activity__c> completed = [SELECT Id, Name, Completed__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        for (Whiteboard_Item_Activity__c act : completed) {
            act.Completed__c = true;   
        }
        
        try {
             update completed;
             if (indicator) {
                    getCompanyItems();
                    getCompanyTrash();
                } else {
                    getPersonalItems();
                    getPersonalTrash();
                }  
        }
        catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
        return;
    }
    
    public void completedItem() {
        
        //Get the selected item
        List<Whiteboard_Item__c> itemsToComplete = [SELECT id, name, Completed__c from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
        
        //Check the "Completed" checkbox on that item
        for(Integer i=0; i < itemsToComplete.size(); i++)
        {
            itemsToComplete[i].Completed__c = true;
        }
        update itemsToComplete;
        
        if (indicator) {
            getCompanyItems();
            getCompanyTrash();
        } else {
            getPersonalItems();
            getPersonalTrash();
        } 
        
        return;
    }
    
    public void unCompleteItem() {
        
        //Get the selected item
        List<Whiteboard_Item__c> itemsToUnComplete = [SELECT id, name, Completed__c from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
        
        //UnCheck the "Completed" checkbox on that item
        for(Integer i=0; i < itemsToUnComplete.size(); i++)
        {
            itemsToUnComplete[i].Completed__c = false;
        }
                    
        update itemsToUnComplete;
        
        if (indicator) {
            getCompanyItems();
            getCompanyTrash();
        } else {
            getPersonalItems();
            getPersonalTrash();
        } 
        
        return;
    }
    
    public void uncompleteAct() {
        List<Whiteboard_Item_Activity__c> completed = [SELECT Id, Name, Completed__c from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        for (Whiteboard_Item_Activity__c act : completed) {
            act.Completed__c = false;   
        }
        
        try {
             update completed;
             if (indicator) {
                    getCompanyItems();
                    getCompanyTrash();
                } else {
                    getPersonalItems();
                    getPersonalTrash();
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
            getCompanyTrash();
        } else {
            getPersonalItems();
            getPersonalTrash();
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
            getCompanyTrash();
        } else {
            getPersonalItems();
            getPersonalTrash();
        } 
        
        return;
    }
    
    public void setActPriority()  {
        //Get the selected item
        List<Whiteboard_Item_Activity__c> actToGivePriority = [SELECT Id, Name from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        
        //Check the "High Priority" checkbox on that activity
        for(Integer i=0; i < actToGivePriority.size(); i++)
        {
            actToGivePriority[i].High_Priority__c = true;
        }
        update actToGivePriority;
        
        if (indicator) {
            getCompanyItems();
            getCompanyTrash();
        } else {
            getPersonalItems();
            getPersonalTrash();
        } 
        
        return;
    }

    public void unsetActPriority()  {
        //Get the selected item
        List<Whiteboard_Item_Activity__c> actToGivePriority = [SELECT Id, Name from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        
        //unCheck the "High Priority" checkbox on that activity
        for(Integer i=0; i < actToGivePriority.size(); i++)
        {
            actToGivePriority[i].High_Priority__c = false;
        }
        update actToGivePriority;
        
        if (indicator) {
            getCompanyItems();
            getCompanyTrash();
        } else {
            getPersonalItems();
            getPersonalTrash();
        } 
        
        return;
    }

    public void trashItem() {
        
        //Get the selected item
        List<Whiteboard_Item__c> itemsToTrash = [SELECT id, name, Trashed__c from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
        
        //Check the "Trash" checkbox on that item
        for(Integer i=0; i < itemsToTrash.size(); i++)
        {
            itemsToTrash[i].Trashed__c = true;
        }
        update itemsToTrash;
        
        if (indicator) {
            getCompanyItems();
            getCompanyTrash();
        } else {
            getPersonalItems();
            getPersonalTrash();
        } 
        
        return;
    }
    
    public void unTrashItem() {
        
        //Get the selected item
        List<Whiteboard_Item__c> itemsToUnTrash = [SELECT id, name, Trashed__c from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];
        
        //UnCheck the "Trash" checkbox on that item
        for(Integer i=0; i < itemsToUnTrash.size(); i++)
        {
            itemsToUnTrash[i].Trashed__c = false;
        }
                    
        update itemsToUnTrash;

        if (indicator) {
            getCompanyItems();
            getCompanyTrash();
        } else {
            getPersonalItems();
            getPersonalTrash();
        } 
             
        return;
    }

    public void deleteItem() {

        List<Whiteboard_Item__c> goners = [SELECT id, name from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];

            try {
                delete goners;
                if (indicator) {
                    getCompanyItems();
                    getCompanyTrash();
                } else {
                    getPersonalItems();
                    getPersonalTrash();
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
                    getCompanyTrash();
                } else {
                    getPersonalItems();
                    getPersonalTrash();
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
    
    public PageReference save() {
        if (Item.Name == '' || Item.Name == null) {
            return null;   
        }
        try {
            insert Item;
            Item = new Whiteboard_Item__c();
            getCompanyItems();         
        }
        catch(Exception ex) {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    public PageReference saveAct() {
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
    
    public void saveActPersonal() {
        activity.Whiteboard_Item__c = WhiteboardIdPersonal;
        try
        {
            activity.PersonalItem__c = true;
            insert activity;
            activity = new Whiteboard_Item_Activity__c();
            getPersonalItems();    
        }                
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return;
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