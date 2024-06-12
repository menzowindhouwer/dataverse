package edu.harvard.iq.dataverse.export;

import com.google.auto.service.AutoService;
import edu.harvard.iq.dataverse.DatasetVersion;
import edu.harvard.iq.dataverse.DataverseRoleServiceBean;
import edu.harvard.iq.dataverse.export.ddi.DdiExportUtil;
import edu.harvard.iq.dataverse.export.spi.Exporter;
import edu.harvard.iq.dataverse.util.BundleUtil;
import java.io.OutputStream;
import javax.json.JsonObject;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.transform.Source;
import java.util.logging.Logger;

import nl.mpi.tla.util.Saxon;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XsltTransformer;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmDestination;

import net.sf.saxon.stax.XMLStreamWriterDestination;

/**
 *
 * @author Menzo Windhouwer
 */
@AutoService(Exporter.class)
public class CMDExporter implements Exporter {
    public static String DEFAULT_XML_NAMESPACE = "http://www.clarin.eu/cmd/1";
    public static String DEFAULT_XML_SCHEMALOCATION = "https://infra.clarin.eu/CMDI/1.x/xsd/cmd-envelop.xsd";
    public static String DEFAULT_XML_VERSION = "1.2";
    public static final String PROVIDER_NAME = "CMDI";

    private static final Logger logger = Logger.getLogger(CMDExporter.class.getCanonicalName());

    
    @Override
    public String getProviderName() {
        return PROVIDER_NAME;
    }

    @Override
    public String getDisplayName() {
        return "CMDI";
    }

    @Override
    public void exportDataset(DatasetVersion version, JsonObject json, OutputStream outputStream) throws ExportException {
        XdmNode jsonXML = null;
        try {
            jsonXML = Saxon.parseJson(json.toString());
        } catch (SaxonApiException e) {
            throw new ExportException("JSON to CMD failed!", e);
        }
        try {
            // logger.info("MENZO was here!");
            // logger.warning("MENZO was here!");
            // logger.severe("MENZO was here!");
            XsltTransformer toCMD = Saxon.buildTransformer(this.getClass().getResource("/CMD/json2cmdi.xsl")).load();

            toCMD.setSource(jsonXML.asSource());

            XMLStreamWriter xmlw = XMLOutputFactory.newInstance().createXMLStreamWriter(outputStream);
            toCMD.setDestination(new XMLStreamWriterDestination(xmlw));

            toCMD.transform();
            xmlw.flush();
        } catch (XMLStreamException xse) {
            throw new ExportException ("Caught XMLStreamException performing CMD export");
        } catch (SaxonApiException e) {
            throw new ExportException("JSON to CMD failed!", e);
        }
    }

    @Override
    public Boolean isXMLFormat() {
        return true; 
    }
    
    @Override
    public Boolean isHarvestable() {
        return true;
    }
    
    @Override
    public Boolean isAvailableToUsers() {
        return true;
    }
    
    @Override
    public String getXMLNameSpace() throws ExportException {
        return CMDExporter.DEFAULT_XML_NAMESPACE;   
    }
    
    @Override
    public String getXMLSchemaLocation() throws ExportException {
        return CMDExporter.DEFAULT_XML_SCHEMALOCATION;
    }
    
    @Override
    public String getXMLSchemaVersion() throws ExportException {
        return CMDExporter.DEFAULT_XML_VERSION;
    }
    
    @Override
    public void setParam(String name, Object value) {
        // this exporter does not uses or supports any parameters as of now.
    }
}

