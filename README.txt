COMPONENT: quickSelect.cfc
AUTHOR: Jason Presley
DATE: 10/11/08
VERSION: 0.1
PURPOSE: To quickly select a group of options from one multiple select list by clicking on an option or options in a related select list
LICENSE: Common Development and Distribution License (CDDL) Version 1.0
CHANGE HISTORY:
	* 10/11/2008: Component Created (First Release)

PLEASE SEND BUGS TO: qkSel@jasonpresley.net

DESCRIPTION:
The component takes a query with two related columns (such as state and cities, manager and employees, etc) and will generate two multiple option lists. The first list is the quick select list. By selecting and option in this list (A state for example) all of the related options in the second list are selected (all the cities in that state).

EXAMPLE CODE:
<!--- Create a Query selecting the two related columns --->
<cfquery name="myQuery" datasource="DemoDSN">
     SELECT state, rep
     FROM sales
     ORDER BY state
</cfquery>

<!--- Pass the Query and the name of the related columns --->
<cfset quickSelect = CreateObject("component", "cfcs.services.quickSelect") />
<cfset getCode = quickSelect.createQuickSelect(#myQuery#,'rep','state') />

<!--- Three variables are returned. qkSelJS is the Javascript to drive the lists --->
<!--- qkSelMenuA contains the group list and qkSelMenuB contains the item list --->
<!--- Both qkSelMenuA and qkSelMenuB must be placed within the same <form> tag --->
<cfoutput>
     #getCode.qkSelJS#
     <form>
          #getCode.qkSelMenuA#
          #getCode.qkSelMenuB#
     </form>
</cfoutput> 