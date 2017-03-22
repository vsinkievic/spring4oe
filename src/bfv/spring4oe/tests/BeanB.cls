 
 /*------------------------------------------------------------------------
    File        : BeanB
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Wed Mar 22 10:23:51 EET 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class bfv.spring4oe.tests.BeanB: 

	define public property beanA as bfv.spring4oe.tests.BeanA no-undo 
	get.
	set. 

end class.