
using bfv.spring4oe.beans.factory.IBeanDefinitionReader.
using bfv.spring4oe.beans.factory.AbstractBeanDefinitionReader.
using bfv.spring4oe.beans.factory.IBeanRegistry.
using bfv.spring4oe.aop.IAopRegistry.
using bfv.spring4oe.misc.Logger.
using bfv.spring4oe.beans.factory.BeanDefinition.
using bfv.spring4oe.beans.factory.BeanInstantiationException.

block-level on error undo, throw.


class bfv.spring4oe.beans.factory.XmlBeanDefinitionReader inherits AbstractBeanDefinitionReader implements IBeanDefinitionReader:
  
  define private variable xdoc   as handle no-undo.
  define private variable xattr  as handle no-undo.
  define private variable xchild as handle no-undo.
  define private variable xvalue as handle no-undo.
  define private variable xparam as handle no-undo.
  
  
  constructor public XmlBeanDefinitionReader(registry as IBeanRegistry, aopregistry as IAopRegistry):
    super(registry, aopregistry).
  end.
  
  
  method public void LoadDefinitions(source as longchar):
    
    define variable successful as logical no-undo.
    
    create x-document xdoc.
    create x-noderef  xattr.
    create x-noderef  xchild.
    create x-noderef  xvalue.
    create x-noderef  xparam.
    
    
    successful = xdoc:load("longchar", source, false) no-error.
    
    if (not successful) then do:
      Logger:Information("Loading XML failed").
      undo, throw new bfv.spring4oe.beans.factory.NoSuchBeanDefinitionException("Loading XML failed").
    end.
    else 
      Logger:Information("Loading XML OK").
    
    parseDefinitions().
    
    delete object xparam no-error.
    delete object xvalue no-error.
    delete object xchild no-error.
    delete object xattr  no-error.
    delete object xdoc   no-error.
    
  end method.
  
  
  method private void parseDefinitions():
    
    define variable xroot as handle no-undo.
    define variable xnode as handle no-undo.
    define variable i as integer no-undo.
    
    create x-noderef xroot.
    create x-noderef xnode.
    
    xdoc:get-document-element(xroot).
    
    do i = 1 to xroot:num-children:
      
      xroot:get-child(xnode, i).
      
      if (xnode:subtype = "element") then 
      do:
        
        case xnode:name:
          
          when "bean" then
            processBean(xnode).
            
          when "alias" then
            processAlias(xnode).
            
          when "aop:config" then 
            processAop(xnode).
            
        end case. 
        
      end.
      
    end.
    
    delete object xnode no-error.
    delete object xroot no-error.
      
  end method.
  
  
  method private void processBean(xbean as handle):
    
    define variable beandef    as BeanDefinition no-undo.
    define variable beanid     as character      no-undo.
    define variable classname  as character      no-undo.
    define variable scope      as character      no-undo.
    define variable lsingleton as logical        no-undo init true.
    define variable initmethod as character      no-undo.
    define variable factmethod as character      no-undo.
    
    define variable i          as integer no-undo.
    define variable numattr    as integer        no-undo.
    define variable attrval    as character      no-undo.

    define variable numchilds  as integer        no-undo.
        
    
    /* read attributes */
    numattr = num-entries(xbean:attribute-names).
    do i = 1 to numattr:
      
      xbean:get-attribute-node(xattr, entry(i, xbean:attribute-names)).
      attrval = xattr:node-value.
      
      case xattr:name:
        
        when "id" or when "name" then
          beanid = attrval.
        
        when "class" then
          classname = attrval.
          
        when "scope" then
          lsingleton = (attrval <> "prototype").
          
        when "init-method" then
          initmethod = attrval. 
          
        when "factory-method" then 
          factmethod = attrval.
         
      end case.
      
    end.
    
    beandef = new BeanDefinition(classname, lsingleton).
    beandef:InitMethod    = initmethod.
    beandef:FactoryMethod = factmethod.
    
    numchilds = xbean:num-children.
    do i = 1 to numchilds:
      
      xbean:get-child(xparam, i).
      if (xparam:subtype = "element") then do:
        
        case xparam:name:
          
          when "property" then do:
            processProperty(beandef, xparam).
          end.    
          
          when "constructor-arg" then do:
            processConstructorArg(beandef, xparam).
          end.
          
        end case.
        
      end.
      
    end.
    
    
    registry:RegisterBeanDefinition(beanid, beandef).
    
  end method.
  
  
  method private void processProperty(beandef as BeanDefinition, xparam as handle):
    
    define variable referenceprop as logical   no-undo.
    define variable valueprop     as logical   no-undo.
    define variable propertyname  as character no-undo.
    define variable propertyvalue as character no-undo.
    define variable i             as integer   no-undo.
    define variable numattr       as integer   no-undo.
    define variable attrval       as character no-undo.
    

    numattr = num-entries(xparam:attribute-names).
    
    do i = 1 to numattr:
      
      xparam:get-attribute-node(xattr, entry(i, xparam:attribute-names)).
      attrval = xattr:node-value.
      
      case xattr:name:
        
        when "name" then 
          propertyname = attrval.
          
        when "value" then do:
          valueprop = true.
          propertyvalue = attrval.
        end.
        
        when "ref" then do: 
          referenceprop = true.
          propertyvalue = attrval.
        end.
        
      end case.
       
    end.
    
    if (valueprop) then 
      beandef:AddPropertyValue(propertyname, propertyvalue).
    else if (referenceprop) then
      beandef:AddPropertyReference(propertyname, propertyvalue).  
    
  end method.
    
    
  method private void processConstructorArg(beandef as BeanDefinition, xparam as handle):
    undo, throw new BeanInstantiationException("constructor-arg is not supported").
  end method.
  
  
  method private void processAlias(xalias as handle):
    
    define variable cname  as character no-undo.
    define variable calias as character no-undo.
    
    xalias:get-attribute-node(xattr, "name").
    cname = xattr:node-value.
    
    xalias:get-attribute-node(xattr, "alias").
    calias = xattr:node-value.
    
    registry:RegisterAlias(cname, calias).
    
  end method.
  
  
  method private void processAop(xaop as handle):
    
    Logger:Information("AOP info found").
    aopregistry:definitionreader:ProcessAop(xaop).
    
  end method.
  
end class.