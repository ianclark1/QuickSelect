<!---
	COMPONENT: quickSelect.cfc
	AUTHOR: Jason Presley
	DATE: 10/11/08
	PURPOSE: To quickly select a group of options from one multiple select list by clicking on an option or options in a related select list
	CHANGE HISTORY:
		* 10/11/2008: Component Created (First Release)
--->

<cfcomponent name="quickSelect" displayname="Quick Select" output="false" hint="To quickly select a group of options from one multiple select list by clicking on an option or options in a related select list">

	<cffunction name="createQuickSelect" access="public" hint="Returns three variables containing strings of code to output the scripts needed">
		<!--- arguments --->
		<cfargument name="qryA" type="query" required="yes">
		<cfargument name="grpColumn" type="string" required="yes">
		<cfargument name="itemColumn" type="string" required="yes">

		<cfquery name="qryB" dbtype="query">
			SELECT DISTINCT #arguments.grpColumn#
			FROM qryA
			ORDER BY #arguments.grpColumn#
		</cfquery>
		
		<cfset aOptIdx=ArrayNew(1)>
		<cfloop query="qryA">
			<cfset aOptIdx[#qryA.currentrow#]="#Evaluate('qryA.#arguments.itemColumn#')#">
		</cfloop>
		
		<cfset bOptIdx=ArrayNew(1)>
		<cfloop query="qryB">
			<cfset bOptIdx[#qryB.currentrow#]="#Evaluate('qryB.#arguments.grpColumn#')#">
		</cfloop>
		
		<cfsavecontent variable="qkSelJS">
			<cfprocessingdirective suppresswhitespace="true">
				<script language="JavaScript">
					relArray = new Array(1);
					<cfloop index="i" from="1" to="#arrayLen(aOptIdx)#">
						<cfquery name="qryA2" dbtype="query">
							SELECT #arguments.grpColumn#
							FROM qryA
							WHERE #arguments.itemColumn# = '#aOptIdx[i]#'
						</cfquery>
						 <cfloop index="s" from="1" to="#arrayLen(bOptIdx)#">
							<cfif '#bOptIdx[s]#' EQ '#Evaluate("qryA2.#arguments.grpColumn#")#'>
								<cfset bKey = s>
							</cfif>
						</cfloop>
						<cfoutput>
							relArray[#i-1#]= new relAssoc(#i#,#bKey#);
						</cfoutput>								
					</cfloop>
					
					//PLACE THE PASSED IDs INTO THE THIS SCOPE TO MAKE THEM EASILY AVAILABLE TO THE OTHER FUNCTIONS
					function relAssoc(aIdx,bIDx)
					{
						this.aIdx = aIdx;
						this.bIDx = bIDx;
					}
					
					//THIS FUNCTION SELECTS ALL OF THE SINGLE ITEMS ASSOCIATED WITH THE GROUP OPTION CHOSEN
					function selectRelated(form)
					{	
						var SelectFrom = form.menuA;
						var SelectedIndex = form.menuA.options.selectedIndex;
						
						//CLEAR FORM OF ALL CURRENT SELECTIONS
						for (x = 0; x <<cfoutput>#qryA.recordcount+1#</cfoutput>; x++){form.menuB.options[x].selected = 0;}
						
						//LOOP THOUGH ALL POSSIBLE GROUP FORM OPTIONS
						for (i=0; i < SelectFrom.options.length; i++){
							
							 //IF THE SELECTED ITEM OF MENU A IS 0 (--ALL--) SELECT ALL OPTIONS IN MENU B
							 if(SelectedIndex == 0) {
							 	for(x = 1; x<<cfoutput>#qryA.recordcount+1#</cfoutput>; x++)
							 	{
							 		eval('form.menuB.options[x].selected=1');
							 	}
							 
							 //OTHERWISE LOOP THROUGH AND SELECT MENU B OPTIONS ASSOCIATED WITH THE MENU A SELECTION(S)
							 } else {
							  	 
							  	 //IF THE MENU A IS SELECTED
						     	 if(form.menuA.options[i].selected) 
								 {
								 	QkSel = form.menuA.options[i].value;
								 	
								 	//LOOP THROUGH ALL THE MENU B OPTIONS
									for (x = 0; x <<cfoutput>#qryA.recordcount#</cfoutput>; x++)
									{
										//IF THE MENU b VALUE IN THE RELARRAY MATCHES THE SELECTED MENU A OPTION THEN SELECT THAT MENU B OPTION IN THE LIST
										if(relArray[x].bIDx == QkSel)
										{
											eval('form.menuB.options[relArray[x].aIdx].selected=1');
										}
									}
								}
							}
						}
					}
				
					//THIS FUNCTION CLEARS ALL OF THE SELECTED OPTIONS IN THE MENU A SELECTION BOX
					function clearA(form)
					{
						for (x = 0; x <<cfoutput>#qryB.recordcount#</cfoutput>; x++){form.menuA.options[x].selected = 0;}
					}
				</script>
			</cfprocessingdirective>
		</cfsavecontent>
		
		<cfsavecontent variable="qkSelMenuA">				
			<select name="menuA" size="10" multiple onChange="selectRelated(this.form)">
				<option value="0">--- All --- </option>
				<cfloop index="i" from="1" to="#arrayLen(bOptIdx)#">
					<cfoutput>
						<option value="#i#">#bOptIdx[i]#</option>
					</cfoutput>
				</cfloop>
			</select>
		</cfsavecontent>
		
		<cfsavecontent variable="qkSelMenuB">
			<select name="menuB" size="10" multiple onChange="clearA(this.form)">
				<option value="0">--- Select ---</option>
				<cfloop index="i" from="1" to="#arrayLen(aOptIdx)#">
					<cfoutput>
						<option value="#i#">#aOptIdx[i]#</option>
					</cfoutput>
				</cfloop>
			</select>
		</cfsavecontent>
		
		<cfset results = StructNew()>
		<cfset results.qkSelJS = qkSelJS>
		<cfset results.qkSelMenuA = qkSelMenuA>
		<cfset results.qkSelMenuB = qkSelMenuB>
		
		<cfreturn results>
		
	</cffunction>

</cfcomponent>