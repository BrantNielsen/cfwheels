<cffunction name="endFormTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing the closing `form` tag."
	examples=
	'
		<!--- view code --->
		<cfoutput>
		    ##startFormTag(action="create")##
		        <!--- your form controls --->
		    ##endFormTag()##
		</cfoutput>
	'
	categories="view-helper,forms-general" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,submitTag,textField,radioButton,checkBox,passwordField,hiddenField,textArea,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfscript>
		var loc = {};
		if (StructKeyExists(request.wheels, "currentFormMethod"))
		{
			StructDelete(request.wheels, "currentFormMethod");
		}
		loc.returnValue = "</form>";
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="startFormTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing the opening form tag. The form's action will be built according to the same rules as `URLFor`. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		<!--- view code --->
		<cfoutput>
		    ##startFormTag(action="create", spamProtection=true)##
		        <!--- your form controls --->
		    ##endFormTag()##
		</cfoutput>
	'
	categories="view-helper,forms-general" chapters="form-helpers-and-showing-errors" functions="URLFor,endFormTag,submitTag,textField,radioButton,checkBox,passwordField,hiddenField,textArea,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="method" type="string" required="false" hint="The type of method to use in the form tag. `get` and `post` are the options.">
	<cfargument name="multipart" type="boolean" required="false" hint="Set to `true` if the form should be able to upload files.">
	<cfargument name="spamProtection" type="boolean" required="false" hint="Set to `true` to protect the form against spammers (done with JavaScript).">
	<cfargument name="route" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="controller" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="action" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="key" type="any" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="params" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="anchor" type="string" required="false" default="" hint="See documentation for @URLFor.">
	<cfargument name="onlyPath" type="boolean" required="false" hint="See documentation for @URLFor.">
	<cfargument name="host" type="string" required="false" hint="See documentation for @URLFor.">
	<cfargument name="protocol" type="string" required="false" hint="See documentation for @URLFor.">
	<cfargument name="port" type="numeric" required="false" hint="See documentation for @URLFor.">
	<cfscript>
		var loc = {};
		arguments = $args(name="startFormTag", args=arguments);

		// sets a flag to indicate whether we use get or post on this form, used when obfuscating params
		request.wheels.currentFormMethod = arguments.method;

		// set the form's action attribute to the URL that we want to send to
		if (!ReFindNoCase("^https?:\/\/", arguments.action))
		{
			arguments.action = URLFor(argumentCollection=arguments);
		}

		// make sure we return XHMTL compliant code
		arguments.action = toXHTML(arguments.action);

		// deletes the action attribute and instead adds some tricky javascript spam protection to the onsubmit attribute
		if (arguments.spamProtection)
		{
			loc.onsubmit = "this.action='#Left(arguments.action, int((Len(arguments.action)/2)))#'+'#Right(arguments.action, ceiling((Len(arguments.action)/2)))#';";
			arguments.onsubmit = $addToJavaScriptAttribute(name="onsubmit", content=loc.onsubmit, attributes=arguments);
			StructDelete(arguments, "action");
		}

		// set the form to be able to handle file uploads
		if (!StructKeyExists(arguments, "enctype") && arguments.multipart)
		{
			arguments.enctype = "multipart/form-data";
		}

		loc.skip = "multipart,spamProtection,route,controller,key,params,anchor,onlyPath,host,protocol,port";

		// variables passed in as route arguments should not be added to the html element
		if (Len(arguments.route))
		{
			loc.skip = ListAppend(loc.skip, $routeVariables(argumentCollection=arguments));
		}
		
		// need to re-add action here even if it was removed due to being a route variable above
		if (ListFind(loc.skip, "action"))
		{
			loc.skip = ListDeleteAt(loc.skip, ListFind(loc.skip, "action"));
		}

		loc.returnValue = $tag(name="form", skip=loc.skip, attributes=arguments);
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="submitTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing a submit button `form` control. Note: Pass any additional arguments like `class`, `rel`, and `id`, and the generated tag will also include those values as HTML attributes."
	examples=
	'
		!--- view code --->
		<cfoutput>
		    ##startFormTag(action="something")##
		        <!--- form controls go here --->
		        ##submitTag()##
		    ##endFormTag()##
		</cfoutput>
	'
	categories="view-helper,forms-general" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,textField,radioButton,checkBox,passwordField,hiddenField,textArea,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="value" type="string" required="false" hint="Message to display in the button form control.">
	<cfargument name="image" type="string" required="false" hint="File name of the image file to use in the button form control.">
	<cfargument name="disable" type="any" required="false" hint="Whether or not to disable the button upon clicking. (prevents double-clicking.)">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField">
	<cfscript>
		var loc = {};
		arguments = $args(name="submitTag", reserved="type,src", args=arguments);
		loc.returnValue = arguments.prepend;
		loc.append = arguments.append;
		if (Len(arguments.disable))
		{
			loc.onclick = "this.disabled=true;";
			if (!Len(arguments.image) && !IsBoolean(arguments.disable))
			{
				loc.onclick &= "this.value='#JSStringFormat(arguments.disable)#';";
			}
			loc.onclick &= "this.form.submit();";
			arguments.onclick = $addToJavaScriptAttribute(name="onclick", content=loc.onclick, attributes=arguments);
		}
		if (Len(arguments.image))
		{
			// create an img tag and then just replace "img" with "input"
			arguments.type = "image";
			arguments.source = arguments.image;
			StructDelete(arguments, "value");
			StructDelete(arguments, "image");
			StructDelete(arguments, "disable");
			StructDelete(arguments, "append");
			StructDelete(arguments, "prepend");
			loc.returnValue &= imageTag(argumentCollection=arguments);
			loc.returnValue = Replace(loc.returnValue, "<img", "<input");
		}
		else
		{
			arguments.type = "submit";
			loc.returnValue &= $tag(name="input", close=true, skip="image,disable,append,prepend", attributes=arguments);
		}
		loc.returnValue &= loc.append;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="buttonTag" returntype="string" access="public" output="false" hint="Builds and returns a string containing a button `form` control."
	examples=
	'
		<!--- view code --->
		<cfoutput>
		    ##startFormTag(action="something")##
		        <!--- form controls go here --->
		        ##buttonTag(content="Submit this form", value="save")##
		    ##endFormTag()##
		</cfoutput>
	'
	categories="view-helper,forms-general" chapters="form-helpers-and-showing-errors" functions="URLFor,startFormTag,endFormTag,textField,radioButton,checkBox,passwordField,hiddenField,textArea,fileField,select,dateTimeSelect,dateSelect,timeSelect">
	<cfargument name="content" type="string" required="false" hint="Content to display inside the button.">
	<cfargument name="type" type="string" required="false" hint="The type for the button: `button`, `reset`, or `submit`.">
	<cfargument name="value" type="string" required="false" hint="The value of the button when submitted.">
	<cfargument name="image" type="string" required="false" hint="File name of the image file to use in the button form control.">
	<cfargument name="disable" type="any" required="false" hint="Whether or not to disable the button upon clicking (prevents double-clicking).">
	<cfargument name="prepend" type="string" required="false" hint="See documentation for @textField">
	<cfargument name="append" type="string" required="false" hint="See documentation for @textField">
	<cfscript>
		var loc = {};
		arguments = $args(name="buttonTag", args=arguments);

		// add onclick attribute to disable the form button
		if (Len(arguments.disable))
		{
			loc.onclick = "this.disabled=true;";
			if (!Len(arguments.image) && !IsBoolean(arguments.disable))
			{
				loc.onclick &= "this.value='#JSStringFormat(arguments.disable)#';";
			}
			loc.onclick &= "this.form.submit();";
			arguments.onclick = $addToJavaScriptAttribute(name="onclick", content=loc.onclick, attributes=arguments);
		}

		// if image is specified then use that as the content
		if (Len(arguments.image))
		{
			loc.args = {};
			loc.args.type = "image";
			loc.args.source = arguments.image;
			arguments.content = imageTag(argumentCollection=loc.args);
		}

		// save necessary info from arguments and delete afterwards
		loc.content = arguments.content;
		loc.prepend = arguments.prepend;
		loc.append = arguments.append;
		StructDelete(arguments, "content");
		StructDelete(arguments, "image");
		StructDelete(arguments, "disable");
		StructDelete(arguments, "prepend");
		StructDelete(arguments, "append");

		// create the button
		loc.returnValue = loc.prepend & $element(name="button", content=loc.content, attributes=arguments) & loc.append;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$formValue" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfargument name="applyHtmlEditFormat" type="boolean" required="false" default="true" />
	<cfscript>
		var loc = {};
		if (IsStruct(arguments.objectName))
		{
			loc.returnValue = arguments.objectName[arguments.property];
		}
		else
		{
			loc.object = $getObject(arguments.objectName);
			if (application.wheels.showErrorInformation && !IsObject(loc.object))
			{
				$throw(type="Wheels.IncorrectArguments", message="The `#arguments.objectName#` variable is not an object.");
			}
			if (StructKeyExists(loc.object, arguments.property))
			{
				loc.returnValue = loc.object[arguments.property];
			}
			else
			{
				loc.returnValue = "";
			}
		}
		if (arguments.applyHtmlEditFormat)
		{
			loc.returnValue = HTMLEditFormat(loc.returnValue);
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$maxLength" returntype="any" access="public">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfscript>
		var loc = {};
		if (StructKeyExists(arguments, "maxlength"))
		{
			loc.returnValue = arguments.maxlength;
		}
		else if (!IsStruct(arguments.objectName))
		{
			loc.object = $getObject(arguments.objectName);
			if (IsObject(loc.object))
			{
				loc.propertyInfo = loc.object.$propertyInfo(arguments.property);
				if (StructCount(loc.propertyInfo) && ListFindNoCase("cf_sql_char,cf_sql_varchar", loc.propertyInfo.type))
				{
					loc.returnValue = loc.propertyInfo.size;
				}
			}
		}
	</cfscript>
	<cfif StructKeyExists(loc, "returnValue")>
		<cfreturn loc.returnValue>
	</cfif>
</cffunction>

<cffunction name="$formHasError" returntype="boolean" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.returnValue = false;
		if (!IsStruct(arguments.objectName))
		{
			loc.object = $getObject(arguments.objectName);
			if (application.wheels.showErrorInformation && !IsObject(loc.object))
			{
				$throw(type="Wheels.IncorrectArguments", message="The `#arguments.objectName#` variable is not an object.");
			}
			if (ArrayLen(loc.object.errorsOn(arguments.property)))
			{
				loc.returnValue = true;
			}
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$createLabel" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfargument name="label" type="string" required="true">
	<cfargument name="prependToLabel" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.returnValue = arguments.prependToLabel;
		loc.attributes = {};
		for (loc.key in arguments)
		{
			if (CompareNoCase(Left(loc.key, 5), "label") eq 0 && Len(loc.key) gt 5 && loc.key != "labelPlacement")
			{
				loc.attributes[ReplaceNoCase(loc.key, "label", "")] = arguments[loc.key];
			}
		}
		if (StructKeyExists(arguments, "id"))
		{
			loc.attributes.for = arguments.id;
		}
		loc.returnValue &= $tag(name="label", attributes=loc.attributes);
		loc.returnValue &= arguments.label;
		loc.returnValue &= "</label>";
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$formBeforeElement" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfargument name="label" type="any" required="true">
	<cfargument name="labelPlacement" type="string" required="true">
	<cfargument name="prepend" type="string" required="true">
	<cfargument name="append" type="string" required="true">
	<cfargument name="prependToLabel" type="string" required="true">
	<cfargument name="appendToLabel" type="string" required="true">
	<cfargument name="errorElement" type="string" required="true">
	<cfargument name="errorClass" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.returnValue = "";
		arguments.label = $getFieldLabel(argumentCollection=arguments);
		if ($formHasError(argumentCollection=arguments) && Len(arguments.errorElement))
		{
			// the input has an error and should be wrapped in a tag so we need to start that wrapper tag
			loc.returnValue &= $tag(name=arguments.errorElement, class=arguments.errorClass);
		}
		if (Len(arguments.label) && arguments.labelPlacement != "after")
		{
			loc.returnValue &= $createLabel(argumentCollection=arguments);
			if (arguments.labelPlacement == "aroundRight")
			{
				// strip out both the label text and closing label tag since it will be placed after the form input
				loc.returnValue = Replace(loc.returnValue, arguments.label & "</label>", "");
			}
			else if (arguments.labelPlacement == "before")
			{
				// since the entire label is created we can append to it
				loc.returnValue &= arguments.appendToLabel;
			}
			else
			{
				// the label argument is either "around" or "aroundLeft" so we only have to strip out the closing label tag
				loc.returnValue = Replace(loc.returnValue, "</label>", "");
			}
		}
		loc.returnValue &= arguments.prepend;
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$formAfterElement" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfargument name="label" type="string" required="true">
	<cfargument name="labelPlacement" type="string" required="true">
	<cfargument name="prepend" type="string" required="true">
	<cfargument name="append" type="string" required="true">
	<cfargument name="prependToLabel" type="string" required="true">
	<cfargument name="appendToLabel" type="string" required="true">
	<cfargument name="errorElement" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.returnValue = arguments.append;
		arguments.label = $getFieldLabel(argumentCollection=arguments);
		if (Len(arguments.label) && arguments.labelPlacement != "before")
		{
			if (arguments.labelPlacement == "after")
			{
				// if the label should be placed after the tag we return the entire label tag
				loc.returnValue &= $createLabel(argumentCollection=arguments);
			}
			else if (arguments.labelPlacement == "aroundRight")
			{
				// if the text should be placed to the right of the form input we return both the text and the closing tag
				loc.returnValue &= arguments.label & "</label>";
			}
			else
			{
				// the label argument is either "around" or "aroundLeft" so we only have to return the closing label tag
				loc.returnValue &= "</label>";
			}
			loc.returnValue &= arguments.appendToLabel;
		}
		if ($formHasError(argumentCollection=arguments) && Len(arguments.errorElement))
		{
			// the input has an error and is wrapped in a tag so we need to close that wrapper tag
			loc.returnValue &= "</" & arguments.errorElement & ">";
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>

<cffunction name="$getFieldLabel" returntype="string" access="public" output="false">
	<cfargument name="objectName" type="any" required="true">
	<cfargument name="property" type="string" required="true">
	<cfargument name="label" type="string" required="true">
	<cfscript>
		var loc = {};
		loc.object = false;
		if (Compare("false", arguments.label) == 0)
		{
			loc.returnValue = "";
		}
		else
		{
			if (arguments.label == "useDefaultLabel" && !IsStruct(arguments.objectName))
			{
				loc.object = $getObject(arguments.objectName);
				if (IsObject(loc.object))
				{
					loc.returnValue = loc.object.$label(arguments.property);
				}
			}
		}
		if (!StructKeyExists(loc, "returnValue"))
		{
			loc.returnValue = arguments.label;
		}
	</cfscript>
	<cfreturn loc.returnValue>
</cffunction>