<%namespace name="ni" module="nodegraphinfo"/>
<%inherit file="base.mako"/>
<style>
<%include file="geometry.css"/>
</style>


<%
    # Local variables
    # Dictionary of attribute modifications
    self.attrdiffs = None
    # Flag indicating whether or not attribute modifications should be shown
    self.showdiffs = False
    # Flag indicating if attributes should be shown as links.
    self.showattriblinks = False
    # List of attributes already listed in the node graph UI
    self.listedattrs = []
    # Dictionary of the main node's branches
    self.mainbranches = None
%>


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

<%def name="show_attr(d, diff, style, verbose, debug, compact=False)">
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
        % if self.showdiffs:
            % if diff == "New":
                ## Add a plus sign to the left of the attribute
                +
            % elif diff == "Deleted":
                ## Put a strike through the attribute, with the matching
                ## style, so there is no small white line partway through
                <s class="${style} value">
            % elif diff == "Changed":
                ## Embolden the attribute
                <strong>
            % endif
        % endif
        ## Deleted attributes should NOT get a visualizer link. Also, if the
        ## dialog is not pinnable, there's no way to interact with it, so no
        ## point in having deceptive links.
        % if (self.showdiffs and diff == "Deleted") or not self.showattriblinks:
            <tt class="${style} value">${ d["Label"] }</tt>
        % else:
            <a class="${style} value" href="attrib://${style}/${d['Name']}">${ d["Label"] }</a>
        % endif
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
            % if diff == "Deleted":
                ## Close off the strike-through tag
                </s>
            % elif diff == "Changed":
                ## Close off emboldening tag
                </strong>
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
            limit = min(20, len(rows))
    %>

    % if rows:
        %for i, row in enumerate(rows[:limit]):
            <%
                # Get a dictionary containing information for this individual
                # attribute
                d = dict(zip(heads, row))
                d["Label"] = d["Name"]
                decoded_name = hou.decode(d["Label"])
                if decoded_name != d["Label"]:
                    d["Label"] = decoded_name + " (" + d["Label"] + ")"
            %>
            % if (d["Name"], branch.name()) not in self.listedattrs:
                <%
                    # Indicate the type of modification, if any, is associated
                    # with this attribute
                    diff = None
                    if not self.attrdiffs:
                        pass
                    elif ((d["Name"], branch.name())
                            in self.attrdiffs["New Attrs"]):
                        diff = "New"
                    elif ((d["Name"], branch.name())
                            in self.attrdiffs["Deleted Attrs"]):
                        diff = "Deleted"
                    elif ((d["Name"], branch.name())
                            in self.attrdiffs["Changed Attrs"]):
                        diff = "Changed"
                %>
                % if i:
                    <br/>
                % endif
                ${ show_attr(d, diff, style, verbose, debug, compact) }
                <%
                    self.listedattrs.append((d["Name"], branch.name()))
                %>
            % endif
        %endfor
        % if limit < len(rows):
            <br/>
            <a href="more:${showname}">${len(rows) - limit} more...</a>
        % endif
    % endif
</%def>

<%def name="show_attrs(allbranches, name, style, renames, verbose, debug, compact=False)">
    <%
        # Get the rows of the main node's branch and input node's branch (if
        # available)
        mainrows = []
        if self.mainbranches is not None and name in self.mainbranches:
            mainrows = self.mainbranches[name].rows()
        inputrows = None

        # If the showdiffs flag is True and the list of branches in
        # allbranches includes branches from both main and input nodes,
        # determine if input branch has rows, whether or not there are
        # changed attributes, and if all rows in the input branch rows are
        # already in the main branch rows
        if self.showdiffs and len(allbranches[name]) > 1:
            inputrows = allbranches[name][1].rows()
            haschanges = (self.attrdiffs["Changed Attrs"] != [])
            issubset = set(inputrows).issubset(set(mainrows))
    %>
    % if any(branch.rows() for branch in allbranches[name]):
        <tr>
            <td width="80" class="attrhead key">
                % if len(mainrows) == 0: # If all attributes were deleted
                    ${'0'}
                % else:
                    ${ len(mainrows) if len(mainrows) > 1 else '1' }
                % endif
                ${ renames.get(name, name) }
            </td>
            <td>
                % for branch in allbranches[name]:
                    % if mainrows and inputrows \
                            and branch == allbranches[name][1] \
                            and not issubset and not haschanges:
                        ## Put a comma in front of the listed attributes from
                        ## this input node branch so that all listed
                        ## attributes appear to belong to the same branch in
                        ## node graph UI
                        ,
                    % endif
                    ${ list_attrs(branch, style, verbose, debug, compact=compact) }
                % endfor
            </td>
        </tr>
    % endif
</%def>

<%def name="volume_detail(d, name, label=None)">
    <span class="key">${label if label is not None else name}:</span>
    <span class="data">${ ni.format_number(d[name]) }</span>
</%def>


<%def name="parse_openvdb_point_info(d, key, value_renames=dict())">
    <%
        details = []
        for item in d.split(', '):
            # groups use parentheses to store member count, so replace with square brackets
            item = item.replace('(','[').replace(')',']')
            words = item.split('[')
            name = words[0]
            value = words[1].split(']')[0]
            subvalue = value.split('_')[-1] if '_' in value else ''
            value = value.split('_')[0]
            if value in value_renames:
                value = value_renames[value]
            # width usually represents stride or 'dynamic'
            width = words[2].split(']')[0] if len(words) > 2 else 1
            try:
                width = int(width)
            except ValueError:
                pass
            details.append((name, value, width, subvalue))
    %>
    <td>
        <p style="margin-left: 10px;">
            <span class="key">${len(details)} ${key}</span>
        </p>
    </td>
    <td colspan="2">
        % for i, (name, value, width, subvalue) in enumerate(details):
            % if i > 0:
                ,
            % endif
            <tt class="points value">${name}</tt>
            % if type(width) is not int:
                <tt class="details">${value}<sub>${width}</sub></tt>
            % elif width > 1:
                <tt class="details">${width}${value}</tt>
            % else:
                <tt class="details">${value}</tt>
            % endif
            % if subvalue != '':
                <tt class="details"><sub>${subvalue}</sub></tt>
            % endif
        % endfor
    </td>
</%def>


<%def name="show_volumes(volbranch, style, verbose)">
    <%
        heads = volbranch.headings()
        rows = volbranch.rows()
        page = pageclass(rows, page=pages[style] + 1, items_per_page=pagesize)
        if style == "volumes":
            itemtype = "volumes"
        else:
            itemtype = "VDBs"
    %>
    % if page.page_count > 1:
        <tr>
            <td colspan="3">
                Showing ${itemtype} ${ page.first_item } to ${ page.last_item } of ${ len(rows) }
                <br>
                ${ page.pager(
                    format="$link_first $link_previous ~3~ $link_next $link_last",
                    url="setpage:%s/$page" % style,
                    symbol_first="First",
                    symbol_last="Last",
                    symbol_previous="&#x2190;",
                    symbol_next="&#x2192;"
                ) }
            </td>
        </tr>
    % endif
    % for row in page:
        <%
            d = dict(zip(heads, row))
            name = d["Name"]
            points = itemtype == "VDBs" and d.get("Type", "").startswith('ptdataidx')
            pointattrs = d.get('Point Attributes')
            pointgroups = d.get('Point Groups')
        %>
        <tr>
            <td class="${style} volumename" width="80">
                <small>&#x2601;</small> ${ name if name else d["Primitive"] }
            </td>
            <td width="120">${ d["Resolution"] }</td>
            <td>
                <span class="volumetype">${ type }</span>
                % if points:
                    <span class="volumetype">points</span>
                    ${ volume_detail(d, "Point Count", "Points") }
                % else:
                    <span class="volumetype">${ d.get("Type", "") }</span>
                    ${ volume_detail(d, "Voxel Count", "Voxels") }
                % endif

        % if "Voxel Size" in d:
            ${ volume_detail(d, "Voxel Size") }
        % endif

                % if verbose:
                    % if points:
                        ${ volume_detail(d, "Voxel Count", "Voxels") }
                    % else:
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
                % endif
            </td>
        </tr>
        % if points:
            % if pointattrs != 'none' and pointattrs != '':
                <tr>
                    <%
                        # shorten some common types for improved readibility
                        renames = dict()
                        if not verbose:
                            renames['float'] = 'flt'
                            renames['double'] = 'dbl'
                            renames['int32'] = 'int'
                        parse_openvdb_point_info(pointattrs, 'Attrs', renames)
                    %>
                </tr>
            % endif
            % if pointgroups != 'none' and pointgroups != '':
                <tr>
                    <%
                        parse_openvdb_point_info(pointgroups, 'Groups')
                    %>
                </tr>
            % endif
        % endif
    % endfor
</%def>

${ next.body() }
