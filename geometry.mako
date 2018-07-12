<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>
<style>
<%include file="geometry.css"/>
</style>

<%def name="list_groups(branch, style, verbose, debug, compact=False)">
    <%
        mixed = "Mixed" in branch.name()
        heads = branch.headings()
        rows = branch.rows()
        showname = "groups/" + branch.name().replace(" ", "_")
        if verbose or showname in showall:
            limit = len(rows)
        else:
            limit = min(32, len(rows))
    %>
    % if rows:
        %for i, row in enumerate(rows[:limit]):
            <%
                d = dict(zip(heads, row))
                ordered = d["Ordered"] == 'Yes'
                internal = debug and (d["Internal"] == 'Yes')
            %>

            % if i:
                ,
            % endif
            <span class="group unit">
                <tt class = "${style}">${ d["Name"] }</tt> \
                <span class="details">
                    %if mixed:
                        ${ni.format_number(d["Primary Count"])},
                        ${ni.format_number(d["Secondary Count"])}
                    %else:
                        ${ni.format_number(d["Count"])}
                    %endif

                    %if ordered and internal:
                        (ord, internal)
                    %elif ordered:
                        (ord)
                    %elif internal:
                        (internal)
                    %endif
                    % if debug:
                        ID: ${ d["ID"] }
                    % endif
                </span>
            </span>
        %endfor
        % if limit < len(rows):
            <br/>
            <a href="more:${showname}">${len(rows) - limit} more...</a>
        % endif
    % endif
</%def>

<%def name="show_groups(branches, name, style, renames, verbose, debug, cls='grouphead', compact=False)">
    <%
        branch = branches[name]
        rows = branch.rows()
    %>
    % if rows:
        <tr>
            <td width="80" class="${cls} key">
                ${ len(rows) if len(rows) > 1 else '' }
                ${ renames.get(name, name) }
            </td>
            <td>
                ${ list_groups(branch, style, verbose, debug, compact=compact) }
            </td>
        </tr>
    % endif
</%def>

<%def name="show_attr(d, style, verbose, debug, compact=False)">
    <%
        # Attribute qualifier abbreviations
        qual_abbrevs = {
            "Color": "Clr",
            "Position": "Pos",
            "Normal": "Nml",
            "Vector": "Vec",
            "Texture Coord": "Tex",
        }

        datatype = d["Type"]
        dataclass = d["Data Class"]
        size = d.get("Size", "")
        qual = d.get("Qualifier")
        unique = d["Values"]
    %>

    <span class="attr unit">
        <tt class="${style} value">${ d["Name"] }</tt>
        <span class="details">
            %if verbose:
                % if size != '1':
                    ${ size }
                % endif
                ${ datatype }
            % else:
                <tt><span class="hi">${ size if size != "1" else "" }</span>\
${ ni.type_code(dataclass) }\
${ "[]" if "Array" in datatype else "" }</tt>\
%if "(8-bit)" in datatype:
<sub>8</sub>
                %elif "(16-bit)" in datatype:
<sub>16</sub>
                %elif "(64-bit)" in datatype:
<sub>64</sub>
                %endif
            %endif

            % if qual == "Index Pair":
                (Capture)
            % elif qual and qual != "Non-arithmetic":
                (${ qual_abbrevs.get(qual, qual) })
            % endif

            % if verbose:
                -
                <span class="invex unit">
                    %if qual == "Index Pair":
                        ${ unique } &#x2715;
                    %endif
                    ${dataclass}[${size}] in VEX
                </span>
            % elif unique:
                <span class="unique">(${ unique } unique)</span>
            % endif

            % if debug:
                % if d["Scope"] == 'Private':
                    (internal)
                % elif d["Scope"] == 'Group':
                    (group)
                % endif
                ID: ${ d["ID"] }
            % endif

            % if d["Export"]:
                &#8594; ${ d["Export"] }
            % endif
        </span>
    </span>
</%def>

<%def name="list_attrs(branch, style, verbose, debug, compact=False)">
    <%
        heads = branch.headings()
        rows = branch.rows()
        showname = "attrs/" + branch.name().replace(" ", "_")
        if verbose or showname in showall:
            limit = len(rows)
        else:
            limit = min(32, len(rows))
    %>

    % if rows:
        %for i, row in enumerate(rows[:limit]):
            % if i:
                ,
            % endif
            ${ show_attr(dict(zip(heads, row)), style, verbose, debug, compact) }
        %endfor
        % if limit < len(rows):
            <br/>
            <a href="more:${showname}">${len(rows) - limit} more...</a>
        % endif
    % endif
</%def>

<%def name="show_attrs(branches, name, style, renames, verbose, debug, compact=False)">
    <%
        branch = branches[name]
        rows = branch.rows()
    %>
    % if rows:
        <tr>
            <td width="80" class="attrhead key">
                ${ len(rows) if len(rows) > 1 else '' }
                ${ renames.get(name, name) }
            </td>
            <td>
                ${ list_attrs(branch, style, verbose, debug, compact=compact) }
            </td>
        </tr>
    % endif
</%def>

<%def name="volume_detail(d, name, label=None)">
    <span class="key">${label if label is not None else name}:</span>
    <span class="data">${ ni.format_number(d[name]) }</span>
</%def>

<%def name="show_volumes(volbranch, style, verbose)">
    <%
        heads = volbranch.headings()
        rows = volbranch.rows()
    %>
    % for row in rows:
        <%
            d = dict(zip(heads, row))
            name = d["Name"]
        %>
        <tr>
            <td class="${style} volumename" width="80">
                <small>&#x2601;</small> ${ name if name else d["Primitive"] }
            </td>
            <td width="120">${ d["Resolution"] }</td>
            <td>
                <span class="volumetype">${ d.get("Type", "")}</span>
                ${ volume_detail(d, "Voxel Count", "Voxels") }

		% if "Voxel Size" in d:
		    ${ volume_detail(d, "Voxel Size") }
		% endif

                % if verbose:
                    % if "Display Mode" in d:
                        ${ volume_detail(d, "Display Mode", "Display")}
                    % endif

                    ## VDB volumes have extra information
                    % if "Type" in d:
                        ${ volume_detail(d, "Background", "BG") }
                        ${ volume_detail(d, "Class") }
                        ${ volume_detail(d, "Display Iso", "D.Iso") }
                        ${ volume_detail(d, "Display Density", "D.Density") }
                    % endif
                % endif
            </td>
        </tr>
    % endfor
</%def>

${ next.body() }
