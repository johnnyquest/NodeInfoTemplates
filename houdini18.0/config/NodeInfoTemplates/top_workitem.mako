<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>

<style>
<%include file="base.css"/>
<%include file="top.css"/>
p { margin: 0; padding: 0;}
</style>

<%def name="list_numbers(attrib)">
    <tt>
    % for i, item in enumerate(attrib.values):
        <span class="unit">${ni.format_number(item)}</span>${", " if (i < len(attrib) - 1) else ""}
    % endfor
    </tt>
</%def>

<%def name="list_strings(attrib)">
    % if len(attrib) == 1 and attrib.hasFlag(pdg.attribFlag.Operator):
        <a href="node:${attrib[0]}">${attrib[0]}</a>
    % else:
	<tt>
	% for i, item in enumerate(attrib.values):
	    <span>${item | h}</span>${", " if (i < len(attrib) - 1) else ""}
	% endfor
	</tt>
    % endif
</%def>

<%def name="list_files(attrib)">
    % for i, item in enumerate(attrib.values):
	<% local_path = scheduler.localizePath(item.path.replace('\\', '/')) %>
	<% hip = hou.expandString("$HIP") %>
	<% display_path = local_path.replace(hip, "$HIP") if hip else local_path %>
	<% prefix = ni.until_colon(local_path) %>
	<p>
	% if localized:
	    % if prefix in ("file", "http", "https", "ftp"):
		<a href="${local_path}">${local_path}</a>
	    % else :
		<a href="file:${local_path}?${item.tag}">${display_path}</a>
	    % endif
	% else:
	    <span>${item.path}</span>
	% endif
        <span class="resultdatatag">${item.tag}</span>
	</p>
    % endfor
</%def>

<%def name="list_python(attrib)">
    <span>${str(attrib.object) | h}</span>
</%def>

<%def name="list_geometry(attrib)">
    <span>${attrib.description | h}</span>
</%def>

<%def name="list_flags(attrib)">
    <% flags = [] %>
    % if attrib.hasFlag(pdg.attribFlag.EnvExport):
	<% flags.append("Exported") %>
    % endif
    % if attrib.hasFlag(pdg.attribFlag.NoCopy):
	<% flags.append("No Copy") %>
    % endif

    % if len(flags) > 0:
	<span class="resultdatatag">[
	% for i, item in enumerate(flags):
	    ${item | h}${", " if (i < len(attrib) - 1) else ""}
	% endfor
	]</span>
    %endif
</%def>

<%def name="list_attrib(key, attrib, css_class)">
    % if not attrib.hasFlag(pdg.attribFlag.Internal):
	<tr>
	% if len(attrib) > 1:
	    <td class="${css_class} data key">${key}
		<span class="arraysize">[${len(attrib)}]</span>
	    </td>
	% else:
	    <td class="${css_class} data key">${key}</td>
	% endif

	<td class="${css_class} value">
	% if attrib.type == pdg.attribType.String:
	    ${list_strings(attrib)}
	% elif attrib.type == pdg.attribType.File:
	    ${list_files(attrib)}
	% elif attrib.type == pdg.attribType.PyObject:
	    ${list_python(attrib)}
	% elif attrib.type == pdg.attribType.Geometry:
	    ${list_geometry(attrib)}
	% else:
	    ${list_numbers(attrib)}
	% endif
	</td>

	${list_flags(attrib)}
	</tr>
    % endif
</%def>

<%
	string_names = task.attribNames(pdg.attribType.String) + task.attribNames(pdg.attribType.File)
	int_names = task.attribNames(pdg.attribType.Int)
	float_names = task.attribNames(pdg.attribType.Float)
	pyobject_names = task.attribNames(pdg.attribType.PyObject)
	geo_names = task.attribNames(pdg.attribType.Geometry)
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
	% if task.batchParent is not None:
	<tr>
		<td class="key">Batch Name</td>
		<td class="value">${task.batchParent.name}</td>
	</tr>
	<tr>
		<td class="key">Batch Index</td>
		<td class="value">${task.batchIndex}</td>
	</tr>
	% endif
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
		<td class="value">${command | h}</td>
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
                    <a href="${value}">${display | h}</a>
                % elif value.startswith("/") or value.startswith("\\") or (len(prefix) == 1 and prefix.isalpha()):
                    ## Unix or Windows file path
                    <a href="file:${value.replace("\\", "/")}?${tag}">${display | h}</a>
                % else:
                    ## Otherwise not clickable
                    <tt>${display | h}</tt>
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
		%for result in expected_results:
		    <p><tt>${result.path}</tt></p>
		    <span class="resultdatatag">${result.tag}</span>
		%endfor
		</td>
	</tr>
	% endif

	%if status_uri and task.isOutOfProcess:
        <tr>
            <td class="key">Job Details</td>
            <td><a href="${status_uri}">${status_uri}</a></td>
        </tr>
	%endif

	%for key in sorted(string_names):
	    ${list_attrib(key, task[key], "strings")}
	%endfor

	%for key in sorted(int_names):
	    ${list_attrib(key, task[key], "ints")}
	%endfor

	%for key in sorted(float_names):
	    ${list_attrib(key, task[key], "floats")}
	%endfor

	%for key in sorted(pyobject_names):
	    ${list_attrib(key, task[key], "pyobjects")}
	%endfor

	% for key in sorted(geo_names):
	    ${list_attrib(key, task[key], "geometry")}
	%endfor

	%if partitions:
        <tr>
            <td class="key">${len(partitions)} Partitioned Items</td>
            <td class="value">
            %for i, part in enumerate(partitions):
		<a href="workitem:${pdg_node.context.name}/${part.node.name}/${part.name}">
		%if part.isUnsuccessful:
		    <span class="Failed">${part.name}</span>
		% else:
		    ${part.name}
		%endif
                ${", " if (i < len(partitions) - 1) else ""}
		</a>
            %endfor
            </td>
        </tr>
	%endif
</table>
