
using bfv.spring4oe.beans.BeansException. 

block-level on error undo, throw.


class bfv.spring4oe.beans.factory.NoSuchBeanDefinitionException inherits BeansException: 
  
  constructor public NoSuchBeanDefinitionException():
    super("NoSuchBeanDefinitionException").
  end.

  constructor public NoSuchBeanDefinitionException(pcMessage as char):
    super(subst("NoSuchBeanDefinitionException: &1", pcMessage)).
  end.
  
end class.