# Responding with Multiple Formats

######Wheels controllers provide some powerful mechanisms for responding to requests for content in XML, JSON, and other formats. Build an API with ease with these functions.

If you've ever needed to create an XML or JSON API for your Wheels application, 
you may have needed to go down the path of creating a separate controller or 
separate actions for the new format. This introduces the need to duplicate model
calls or even break them out into a super long list of before filters. With 
this, your controllers can get pretty hairy pretty fast.

Using a few Wheels functions, you can easily respond to requests for HTML, XML, 
JSON, and PDF formats without adding unnecessary bloat to your controllers.

## Requesting Different Formats

With Wheels Provides functionality in place, you can request different formats 
using the following methods:

1. URL Variable
1. URL Extension
1. Request Header

Which formats you can request is determined by what you configure in the 
controller. See the section below on *Responding to Different Formats* in the 
Controller for more details.

### 1. URL Variable

Wheels will accept a URL variable called `format`. If you wanted to request the 
XML version of an action, for example, your URL call would look something like 
this:

```html
http://www.example.com/products?format=xml
```

The same would go for JSON:

```html
http://www.example.com/products?format=json
```

### 2. URL Extension

Perhaps a cleaner way is to request the format as a "file" extension. Here are 
the XML and JSON examples, respectively:

```html
http://www.example.com/products.xml
http://www.example.com/products.json
```

This works similarly to the *URL variable* approach mentioned above in that 
there will now be a key in the `params` struct set to the `format` requested. 
With the XML example, there will be a variable at `params.format` with a value 
of `xml`.

### 3. Request Header
If you are calling the Wheels application as a web service, you can also request
a given format via the HTTP `Accept` header.

If you are consuming the service with another Wheels application, your 
`<cfhttp>` call would look something like this:

```cfml
<cfhttp url="http://www.example.com/products">
    <cfhttpparam type="header" name="Accept" value="application/octet-stream">
</cfhttp>
```

In this example, we are sending an `Accept` header with the value for the `xml` 
format.

Here is a list of values that you can grab from [mimeTypes()][1] with Wheels out
of the box.

1. `html`
1. `xml`
1. `json`
1. `csv`
1. `pdf`
1. `xls`

You can use [addFormat()][2] to set more types to the appropriate MIME type for 
reference. For example, we could set a Microsoft Word MIME type in 
`config/settings.cfm` like so:

```cfml
<cfset addFormat(extension="doc", mimeType="application/msword")>
```

## Responding to Different Formats in the Controller

The fastest way to get going with creating your new API and formats is to call 
[provides()][3] from within your controller's `init()` method.

Take a look at this example:

```cfml
<cfcomponent extends="Controller">

    <cffunction name="init">
        <cfset provides("html,json,xml")>
    </cffunction>

    <cffunction name="index">
        <cfset products = model("product").findAll(order="title")>
        <cfset renderWith(products)>
    </cffunction>

</cfcomponent>
```

By calling the [provides()][3]function in `init()`, you are instructing the 
Wheels controller to be ready to provide content in a number of formats. 
Possible choices to add to the list are `html` (which runs by default), `xml`, 
`json`, `csv`, `pdf`, and `xls`.

This is coupled with a call to [renderWith()][4] in the following actions. 
In the example above, we are setting a query result of products and passing it 
to [renderWith()][4]. By passing our data to this function, Wheels gives us the 
ability to respond to requests for different formats, and it even gives us the 
option to just let Wheels handle the generation of certain formats 
automatically.

When Wheels handles this response, it will set the appropriate MIME type in the 
`Content-Type` HTTP header as well.

### Providing the HTML Format
Responding to requests for the HTML version is the same as you're already used 
to with [Rendering Content][6]. [renderWith()][4] will accept the same arguments
as [renderPage()][5], and you create just a view template in the `views` folder
like normal.

### Automatic Generation of XML and JSON Formats
If the requested format is `xml` or `json`, the [renderWith()][4] function will 
automatically transform the data that you provide it. If you're fine with what 
the function produces, then you're done!

### Providing Your Own Custom Responses
If you need to provide content for another type than `xml` or `json`, or if you 
need to customize what your Wheels application generates, you have that option.

In your controller's corresponding folder in `views`, all you need to do is 
implement a view file like so:

<table>
<thead>
	<tr>
		<th>Type</th>
		<th>Example</th>
	</tr>
</thead>
<tbody>
	<tr>
		<td><code>html</code></td>
		<td><code>views/products/index.cfm</code></td>
	</tr>
	<tr>
		<td><code>xml</code></td>
		<td><code>views/products/index.xml.cfm</code></td>
	</tr>
	<tr>
		<td><code>json</code></td>
		<td><code>views/products/index.json.cfm</code></td>
	</tr>
	<tr>
		<td><code>csv</code></td>
		<td><code>views/products/index.csv.cfm</code></td>
	</tr>
	<tr>
		<td><code>pdf</code></td>
		<td><code>views/products/index.pdf.cfm</code></td>
	</tr>
	<tr>
		<td><code>xls</code></td>
		<td><code>views/products/index.xls.cfm</code></td>
	</tr>
</tbody>
</table> 

If you need to implement your own XML- or JSON-based output, the presence of 
your new custom view file will override the automatic generation that Wheels 
normally performs.

### Example: PDF Generation

If you need to provide a PDF version of the product catalog, the view file at 
`views/products/index.pdf.cfm` may look something like this:

```cfml
<cfdocument format="pdf">
    <h1>Products</h1>
    <table>
        <thead>
            <tr>
                <th>Name</th>
                <th>Description</th>
                <th>Price</th>
            </tr>
        </thead>
        <tbody>
            #includePartial(products)#
        </tbody>
    </table>
</cfdocument>
```

[1]: TBD
[2]: TBD
[3]: TBD
[4]: TBD
[5]: TBD
[6]: TBD

