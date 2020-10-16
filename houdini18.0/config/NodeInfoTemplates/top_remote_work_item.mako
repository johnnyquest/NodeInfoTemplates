<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>

<style>
<%include file="base.css"/>
<%include file="top.css"/>
p { margin: 0; padding: 0;}
</style>

<%def name="list_numbers(attrib)">
    <tt>
    % for i, item in enumerate(attrib):
        <span class="unit">${ni.format_number(item)}</span>${", " if (i < len(attrib) - 1) else ""}
    % endfor
    </tt>
</%def>

<%def name="list_strings(attrib)">
	<tt>
	% for i, item in enumerate(attrib):
	    <span>${item | h}</span>${", " if (i < len(attrib) - 1) else ""}
	% endfor
	</tt>
</%def>

<%def name="list_files(file_list, tags)">
    % for i, item in enumerate(file_list):
	<% local_path = item %>
	<% hip = hou.expandString("$HIP") %>
	<% display_path = local_path.replace(hip, "$HIP") if hip else local_path %>
	<% prefix = ni.until_colon(local_path) %>
    <% tag = tags[i] if i < len(tags) else '' %>
	<p>
	% if localized:
	    % if prefix in ("file", "http", "https", "ftp"):
		<a href="${local_path}">${local_path}</a>
	    % else :
		<a href="file:${local_path}?${tag}">${display_path}</a>
	    % endif
	% else:
	    <span>${item}</span>
	% endif
        <span class="resultdatatag">${tag}</span>
	</p>
    % endfor
</%def>

<table>
    <tr>
        <td class="key">State</td>
        <td class="${status_class.replace(' ', '')}">${status_label}</td>
    </tr>

    <tr>
        <td class="key">Index</td>
        <td class="value">${wi_index}</td>
    </tr>

    % if has_frame:
    <tr>
        <td class="key">Frame</td>
        <td class="value">${frame}</td>
    </tr>
    % endif

    % if batch_parent_index >= 0:
    <tr>
        <td class="key">Batch Name</td>
        <td class="value">${batch_parent_name}</td>
    </tr>
    
    <tr>
        <td class="key">Batch Index</td>
        <td class="value">${batch_index}</td>
    </tr>    
    % endif

    <tr>
        <td class="key">Priority</td>
        <td class="value">${priority}</td>
    </tr>

    % if no_generate:
    <tr>
        <td class="key">No Generate</td>
        <td class="value">True</td>
    </tr>
    % endif

    % if command:
    <tr>
        <td class="key">Command</td>
        <td class="value">${command | h}</td>
    </tr>
    % endif

    % if cook_time:
    <tr>
        <td class="key">Cook Time</td>
        <td class="value">${cook_time}</td>
    </tr>
    % endif

    % if input_data:
    <tr>
        <td class="key">Input</td>
        <td class="value">
            ${list_files(input_data, input_tag)}
        </td>
    </tr>
    % endif

    % if expected_input_data:
    <tr>
        <td class="key">Expected Input</td>
        <td class="value">
            ${list_files(expected_input_data, expected_input_tag)}
        </td>
    </tr>
    % endif

    % if result_data:
    <tr>
        <td class="key">Output</td>
        <td class="value">
            ${list_files(result_data, result_tag)}
        </td>
    </tr>
    % endif

    % if expected_result_data:
    <tr>
        <td class="key">Expected Output</td>
        <td class="value">
            ${list_files(expected_result_data, expected_result_tag)}
        </td>
    </tr>
    % endif

    % for string_attr in sorted(string_attributes):
    <tr>
        <td class="strings data key">
            ${string_attr}
        </td>
        % if len(string_attributes[string_attr]) > 1:
            <span class="strings arraysize">[${len(string_attributes[string_attr])}]</span>
        % endif
        <td class="strings value">${list_strings(string_attributes[string_attr])}</td>
    </tr>
    % endfor

    % for int_attr in sorted(int_attributes):
    <tr>
        <td class="ints data key">
            ${int_attr}
        </td>
        % if len(int_attributes[int_attr]) > 1:
            <span class="ints arraysize">[${len(int_attributes[int_attr])}]</span>
        % endif
        <td class="ints value">${list_numbers(int_attributes[int_attr])}</td>
    </tr>
    % endfor

    % for float_attr in sorted(float_attributes):
    <tr>
        <td class="floats data key">
            ${float_attr}
        </td>
        % if len(float_attributes[float_attr]) > 1:
            <span class="floats arraysize">[${len(float_attributes[float_attr])}]</span>
        % endif
        <td class="floats value">${list_numbers(float_attributes[float_attr])}</td>
    </tr>
    % endfor
</table>
