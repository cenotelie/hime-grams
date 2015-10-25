/**
 * Some utility API for RDF
 * @author Laurent Wouters
 */

/**
 * @const The default URI mappings for shortening the displayed URIs
 */
var DEFAULT_URI_MAPPINGS = [
    ["rdf", "http://www.w3.org/1999/02/22-rdf-syntax-ns#"],
    ["rdfs", "http://www.w3.org/2000/01/rdf-schema#"],
    ["xsd", "http://www.w3.org/2001/XMLSchema#"],
    ["owl", "http://www.w3.org/2002/07/owl#"]];
/**
 * @const {string} List of distinctive parts of URIs that are known to point to targets
 * For these URIs external links will be generated.
 */
var KNOWN_TARGETS = [];

/**
 * Generates the NQuad serialization of a RDF node
 * 
 * @method getNQForRDF
 * @param {object} value The RDF node
 * @return The NQuad serialization
 */
function getNQForRDF(value) {
    if (value.type === "uri" || value.type === "iri") {
        return "<" + value.value + ">";
    } else if (value.type === "bnode") {
        return "_:" + value.value;
    } else if (value.type === "blank") {
        return "_:" + value.id;
    } else if (value.hasOwnProperty("lexical")) {
        return getNQForLiteral(value.lexical, value.lang, value.datatype);
    } else {
        return getNQForLiteral(value.value, value.hasOwnProperty("xml:lang") ? value["xml:lang"] : null, value.datatype);
    }
}

/**
 * Generates the NQuad serialization for an RDF literal node
 * 
 * @method getNQForLiteral
 * @param {string} lexical The literal's lexical value
 * @param {string} langTag The literal's language tag, if any
 * @param {string} datatype the literal's datatype, if any
 * @return {string} The NQuad serialization
 */
function getNQForLiteral(lexical, langTag, datatype) {
    var result = "\"";
    result += lexical.replace(new RegExp("\"", 'g'), "\\\"");
    result += "\"";
    if (langTag !== null) {
        result += "@" + langTag;
    } else if (datatype !== null && datatype !== "http://www.w3.org/2001/XMLSchema#string") {
        result += "^^<";
        result += datatype;
        result += ">";
    }
    return result;
}

/**
 * Generates the HTML tag for a RDF node
 * 
 * @mathod getHTMLForRDF
 * @param {object} the RDF node
 * @return The generated HTML code
 */
function getHTMLForRDF(value) {
    if (value.type === "uri" || value.type === "iri") {
        return getHTMLForIRI(value.value);
    } else if (value.type === "bnode") {
        return getHTMLForBlank(value.value);
    } else if (value.type === "blank") {
        return getHTMLForBlank(value.id);
    } else if (value.type === "variable") {
        return getHTMLForVariable(value.value);
    } else if (value.hasOwnProperty("lexical")) {
        return getHTMLForLiteral(value.lexical, value.lang, value.datatype);
    } else {
        return getHTMLForLiteral(value.value, value.hasOwnProperty("xml:lang") ? value["xml:lang"] : null, value.datatype);
    }
}

/**
 * Generates the HTML tag for linking to a RDF IRI node
 * 
 * @method getHTMLForIRI
 * @param {string} uri The URI to link to
 * @param {string?} name The name to display, if any
 * @return {string} The generated HTML code
 */
function getHTMLForIRI(uri, name) {
    var toDisplay = name;
    if (typeof name === "undefined" || name === null || name === "") {
        toDisplay = uri;
        for (var i = 0; i != DEFAULT_URI_MAPPINGS.length; i++) {
            if (uri.startsWith(DEFAULT_URI_MAPPINGS[i][1])) {
                toDisplay = DEFAULT_URI_MAPPINGS[i][0] + ":" + uri.substring(DEFAULT_URI_MAPPINGS[i][1].length);
                break;
            }
        }
    }
    var result = "<a class=\"rdf-iri\" href=\"resource.html?endpoint=";
    result += encodeURI(document.getElementById("endpoint").value);
    result += "&uri=";
    result += encodeURI(uri).replace(new RegExp("#", 'g'), "%23");
    result += "\">";
    result += toDisplay;
    result += "</a>";
    for (var i = 0; i != KNOWN_TARGETS.length; i++) {
        if (uri.contains(KNOWN_TARGETS[i])) {
            result += " <a href=\"";
            result += uri;
            result += "\" style=\"font-size:50%\"><img src=\"static/goto.svg\" width=\"16px\" height=\"16px\"></a>";
            break;
        }
    }
    return result;
}

/**
 * Generates the HTML tag for linking to a rule
 * 
 * @method getHTMLForRule
 * @param {string} uri The rule's URI to link to
 * @return {string} The generated HTML code
 */
function getHTMLForRule(uri) {
    var toDisplay = uri;
    for (var i = 0; i != DEFAULT_URI_MAPPINGS.length; i++) {
        if (uri.startsWith(DEFAULT_URI_MAPPINGS[i][1])) {
            toDisplay = DEFAULT_URI_MAPPINGS[i][0] + ":" + uri.substring(DEFAULT_URI_MAPPINGS[i][1].length);
            break;
        }
    }
    var result = "<a class=\"rdf-iri\" href=\"rule.html?endpoint=";
    result += encodeURI(document.getElementById("endpoint").value);
    result += "&uri=";
    result += encodeURI(uri).replace(new RegExp("#", 'g'), "%23");
    result += "\">";
    result += toDisplay;
    result += "</a>";
    return result;
}

/**
 * Generates the HTML tag for an RDF blank node
 * 
 * @method getHTMLForBlank
 * @param {string} id The blank node identifier
 * @return {string} The generated HTML code
 */
function getHTMLForBlank(id) {
    return "<span class=\"rdf-blank\">_:" + id + "</span>";
}

/**
 * Generates the HTML tag for an RDF literal node
 * 
 * @method getHTMLForLiteral
 * @param {string} lexical The literal's lexical value
 * @param {string} langTag The literal's language tag, if any
 * @param {string} datatype the literal's datatype, if any
 * @return {string} The generated HTML code
 */
function getHTMLForLiteral(lexical, langTag, datatype) {
    var result = "<span class=\"rdf-literal\">\"";
    result += lexical;
    result += "\"";
    if (langTag !== null) {
        result += "@" + langTag;
    } else if (datatype !== null && datatype !== "http://www.w3.org/2001/XMLSchema#string") {
        result += "^^&lt";
        result += getHTMLForIRI(datatype);
        result += "&gt";
    }
    result += "</span>";
    return result;
}

/**
 * Generates the HTML tag for an RDF variable node
 * 
 * @method getHTMLForVariable
 * @param {string} name The variable node identifier
 * @return {string} The generated HTML code
 */
function getHTMLForVariable(name) {
    return "<span class=\"rdf-var\">?" + name + "</span>";
}

/**
 * Gets the HTML tag for linking to the explanation of an inferred triple
 * 
 * @method getHTMLForExplanation
 * @param {string} subject Triple subject's IRI
 * @param {string} property Triple property's IRI
 * @param {string} value Triple object's IRI
 * @return {string} The HTML tag serialized as a string
 */
function getHTMLForExplanation(subject, property, value) {
    var quad = "<" + subject + "><" + property + "><" + value + "><" + INFERENCE_GRAPH + ">.";
    var html = "<a class=\"expanation\" href=\"explain.html?endpoint=" + encodeURI(document.getElementById("endpoint").value) + "&quad=";
    html += encodeURIComponent(quad);
    html += "\">?</a>";
    return html;
}
