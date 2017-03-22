 
 /*------------------------------------------------------------------------
    File        : BeanA
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsinkievic
    Created     : Wed Mar 22 10:23:35 EET 2017
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class bfv.spring4oe.tests.BeanA: 

	define public property beanB as bfv.spring4oe.tests.BeanB no-undo 
	get.
	set. 

end class.