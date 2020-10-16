<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>

<style>
<%include file="base.css"/>
<%include file="top.css"/>
p { margin: 0; padding: 0;}
</style>

<%def name="list_numbers(items)">
    % for i, item in enumerate(items):
        <span class="unit">${ni.format_number(item)}</span>${", " if (i < len(items) - 1) else ""}
    % endfor
</%def>

<%def name="list_strings(items)">
    % for i, item in enumerate(items):
        <span>${item}</span>${", " if (i < len(items) - 1) else ""}
    % endfor
</%def>


<%
	if data:
		string_data = data.stringDataMap
		int_data = data.intDataMap
		float_data = data.floatDataMap
	else:
	    string_data = []
	    int_data = []
	    float_data = []
%>

<table>
	<tr>
		<td class="key">State</td>
		<td class="${status_class.replace(' ', '')}">${status_label}</td>
	</tr>
	<tr>
		<td class="key">Index</td>
		<td class="value">${taskindex}</td>
	</tr>
	% if taskframe is not None:
	<tr>
		<td class="key">Frame</td>
		<td class="value">${taskframe}</td>
	</tr>
	%endif
	<tr>
		<td class="key">Priority</td>
		<td class="value">${priority}</td>
	</tr>

	%if nogenerate:
	<tr>
		<td class="key">No Generate</td>
		<td class="value">True</td>
	</tr>
	%endif

	%if command:
	<tr>
		<td class="key">Command</td>
		<td class="value">${command}</td>
	</tr>
	%endif

	%if cooktime:
	<tr>
		<td class="key">Cook Time</td>
		<td class="value">${cooktime}</td>
	</tr>
	%endif

	% if inputs:
	<tr>
		<td class="key">Input</td>
		<td class="value">
		%for value, display, tag in inputs:
		    <p>
                <% prefix = ni.until_colon(value) %>
                % if prefix in ("file", "http", "https", "ftp"):
                    ## Clickable URLs
                    <a href="${value}">${display}</a>
                % elif value.startswith("/") or value.startswith("\\") or (len(prefix) == 1 and prefix.isalpha()):
                    ## Unix or Windows file path
                    <a href="file:${value.replace("\\", "/")}?${tag}">${display}</a>
                % else:
                    ## Otherwise not clickable
                    <tt>${display}</tt>
                % endif
                <span class="resultdatatag">${tag}</span>
            </p>
		%endfor
		</td>
	</tr>
	% endif

	% if results:
	<tr>
		<td class="key">Output</td>
		<td class="value">
		%for value, display, tag in results:
		    <p>
                ## A TOPs "results" string can be anything, we can't assume it's
                ## a URL, unfortunately, so try to handle possibly clickable things
                ## on a case-by-case basis :/
                <% prefix = ni.until_colon(value) %>
                % if prefix in ("file", "http", "https", "ftp"):
                    ## Clickable URLs
                    <a href="${value}">${display}</a>
                % elif value.startswith("/") or value.startswith("\\") or (len(prefix) == 1 and prefix.isalpha()):
                    ## Unix or Windows file path
                    <a href="file:${value.replace("\\", "/")}?${tag}">${display}</a>
                % else:
                    ## Otherwise not clickable
                    <tt>${display}</tt>
                % endif
                <span class="resultdatatag">${tag}</span>
            </p>
		%endfor
		</td>
	</tr>
	% elif expected_results:
	<tr>
		<td class="key">Expected Output</td>
		<td class="value">
		%for value,tag,hash in expected_results:
		    <p><tt>${value}</tt></p>
		    <span class="resultdatatag">${tag}</span>
		%endfor
		</td>
	</tr>
	% endif

	% if environment:
	    % for env_pair in sorted(environment):
	    <tr>
		    <td class="vars data key">${env_pair[0]}</td>
		    <td class="vars value"><tt>${env_pair[1]}</tt></td>
	    </tr>
	    % endfor
	% endif

	%for key in sorted(string_data):
	<tr>
		<td class="strings data key">${key}</td>
		<td class="strings value"><tt>${list_strings(string_data[key])}</tt></td>
	</tr>
	%endfor

	%for key in sorted(int_data):
	<tr>
		<td class="ints data key">${key}</td>
		<td class="ints value"><tt>${list_numbers(int_data[key])}</tt></td>
	</tr>
	%endfor

	%for key in sorted(float_data):
	<tr>
		<td class="floats data key">${key}</td>
		<td class="floats value"><tt>${list_numbers(float_data[key])}</tt></td>
	</tr>
	%endfor

	%if partitions:
        <tr>
            <td class="key">${len(partitions)} Partitioned Items</td>
            <td class="value">
            %for i, part in enumerate(partitions):
		%if part.isUnsuccessful:
		    <span class="Failed">${part.name}</span>
		% else:
		    ${part.name}
		%endif
                ${", " if (i < len(partitions) - 1) else ""}
            %endfor
            </td>
        </tr>
	%endif

	%if status_uri:
        <tr>
            <td class="key">URI</td>
            <td><a href="${status_uri}">${status_uri}</a></td>
        </tr>
	%endif
</table>
