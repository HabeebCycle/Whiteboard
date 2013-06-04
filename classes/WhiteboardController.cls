public with sharing class WhiteboardController {
    
    public String WhiteboardId { get; set; }
    public String WhiteboardIdPersonal { get; set; }
    public Whiteboard_Item_Activity__c activity {get; private set;}
    public Whiteboard_Item__c Item {get; private set;}

    public WhiteboardController() {
        Item = new Whiteboard_Item__c();
        activity = new Whiteboard_Item_Activity__c();
        getWhiteboard();
    }

    public void deleteItem() {

        List<Whiteboard_Item__c> goners = [SELECT id, name from Whiteboard_Item__c where id = :ApexPages.currentpage().getparameters().get('ItemId')];

            try
            {
                delete goners;                
            }            
            catch(Exception ex)
            {
                ApexPages.addMessages(ex);
            }              
        return;
    }
    
    public void deleteAct() {
        List<Whiteboard_Item_Activity__c> goners = [SELECT Id, Name from Whiteboard_Item_Activity__c where id = :ApexPages.currentpage().getparameters().get('ActId')];            
        try 
        {
             delete goners;
        }
        catch (Exception ex) 
        {
            ApexPages.addMessages(ex);
        }
        return;
    }
    
    public Whiteboard_Item__c[] getWhiteboard() {

        return [SELECT Name, Id,
                     (SELECT Name, Due_Date__c, Description__c
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
                         (SELECT Name, Due_Date__c, Description__c
                          FROM Whiteboard_Item_Activities__r
                          WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true
                          ORDER BY CreatedDate 
                          LIMIT 30)
                      FROM Whiteboard_Item__c
                      WHERE CreatedById =: UserInfo.getUserId() AND PersonalItem__c =: true
                      ORDER BY CreatedDate
                      LIMIT 100];
    }
    
    public PageReference save() {

        try
        {
            insert Item;
            Item = new Whiteboard_Item__c();         
        }
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return null;
    }
    
    public PageReference saveAct() {
        activity.Whiteboard_Item__c = WhiteboardId;
        try
        {
            insert activity;
            activity = new Whiteboard_Item_Activity__c();
        }                
        catch(Exception ex)
        {
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
        }                
        catch(Exception ex)
        {
            ApexPages.addMessages(ex);
        }
        return;
    }
    
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