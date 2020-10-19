<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="geometry.mako"/>

<%
    components = (('Points', 'points'), ('Primitives', 'primitives'))
    groups = (('Point Groups', 'points'),)
    attrs = (('Point Attributes', 'points'),)
    counts_to_show = ("Points", "Primitives")
    renames = {
        "Last timestep frame": "Last TS frame",
        "Objects processed last timestep": "Objects last TS",
        "Primitive Groups": "Prim Groups",
        "Point Attributes": "Point Attrs",
        "Primitive Attributes": "Prim Attrs",
    }
%>

<%def name="geo_info(geobranch, verbose, debug)">
    <%
        subbranches = geobranch.branches()
        countbranch = subbranches.get("Counts")
        counts = dict(countbranch.rows()) if countbranch else {}
        intcounts = {}
        for name in counts_to_show:
            value = counts.get(name)
            if value:
                try:
                    value = int(value)
                except ValueError:
                    pass
                else:
                    intcounts[name] = value
    %>

    ## Don't show geometry if it has no points or primitives
    % if any(intcounts.values()):
        <tr>
            <td class="key"><tt>${ geobranch.name() }</tt></td>
            <td>
                <p>
                    % for i, name in enumerate(counts_to_show):
                        % if i:
                            &#x205D;
                        % endif
                        <% value = intcounts[name] %>
                        % if value:
                            <span class="${name.lower()}">
                                <tt>${ ni.format_number(value) }</tt>
                                ${name}
                            </span>
                        % endif
                    % endfor
                </p>

                % if any(name in subbranches for name, _ in attrs):
                    % for name, style in attrs:
                        % if name in subbranches:
                            <p>
                                <span class="key">${ name }:</span>
                            </p>
                            ${ self.list_attrs(subbranches[name], style, verbose, debug, compact=True) }
                        % endif
                    % endfor
                % endif

                % if any(name in subbranches for name, _ in groups):
                    % for name, style in groups:
                        % if name in subbranches:
                            <p>
                                <span class="key">${ name }:</span>
                                ${ self.list_groups(subbranches[name], style, verbose, debug, compact=True) }
                            </p>
                        % endif
                    % endfor
                % endif
            </td>
        </tr>
    % endif
</%def>

<%def name="field_row(branch)">
    <tr>
        <td class="key"><tt>${ branch.name() }</tt></td>
        <td class="value">
            [ ${ ni.prop_value(branch, 'Resolution') } ]
            ${ ni.format_number(ni.prop_value(branch, 'Voxel Count')) } voxels
        </td>
    </tr>
</%def>

<%
    dopinfo = info.branches().get('DOP Info')
    if dopinfo:
        objects = dopinfo.branches().get('Objects', None)
        numobjects = int(ni.prop_value(dopinfo, 'Objects processed last timestep'))
%>

%if dopinfo:
    ${ self.properties(dopinfo, renames=renames, keywidth='100') }

    % if objects:
        <hr/>
        <%
            objbranches = objects.branches()
            objectnames = objects.branchOrder()
        %>
        % for objectnum in objectnames:
            <%
                objbranch = objbranches[objectnum]
		for row in objbranch.rows():
		    if row[0] == 'Name':
			objectname = row[1]
		    elif row[0] == 'Count':
			objectcount = int(row[1])
		    else:
			objectid = int(row[1])
		if debug:
		    objectname += ' : ' + str(objectid)
		if objectcount > 1:
		    objectname += ' (duplicate name)'
                values = objbranch.branches().values()
                geos = [v for v in values if v.infoType() == "Geometry"]
                fields = [v for v in values if v.infoType() == "Field"]
                others = [v for v in values if v.infoType() not in ("Geometry, Field")]
            %>
            <p><tt>${objectname}</tt></p>
            <table>
                % for fbranch in fields:
                    ${ field_row(fbranch) }
                % endfor
                % for gbranch in geos:
                    ${ geo_info(gbranch, verbose, debug) }
                % endfor
                % for obranch in others:
                    ${ self.branch_rows(obranch, recursive=True) }
                % endfor
            </table>
        % endfor

        % if len(objectnames) < numobjects:
            <tr>
                <td class="dopobject">
                    ...and ${numobjects - len(objectnames)} more.
                </td>
            </tr>
        % endif
    % endif
%endif
