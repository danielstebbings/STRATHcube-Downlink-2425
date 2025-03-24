/* Definition of Packet Class 
*/

#include <cereal/archives/portable_binary.hpp>

#include <stdint.h>
#include <assert.h>
#include <climits>
#include <optional>
#include <vector>

static_assert(sizeof(double) * CHAR_BIT == 64, "64-bit double is assumed.");
typedef uint64_t timestamp;

class GSE_Packet {
public:
    struct FixedHeader {
        bool start    : 1;
        bool end      : 1;
        int labelType : 2;
        int GSElength : 12;
        };
    struct VariableHeader {
        std::optional<char>     fragID;
        std::optional<uint16_t> totalLength;
        std::optional<uint16_t> protocolType;
        std::optional<char[3]>  label;
    };
private:
    FixedHeader fh;
    std::optional<VariableHeader> vh;
    Packet* pdu;

public:
    // constructor
    GSE_Packet(FixedHeader fh, VariableHeader vh);
};


class Packet {
    uint8_t type;
    uint8_t version;
    timestamp time;

    virtual cereal::PortableBinaryOutputArchive serialise();


};

std::vector<GSE_Packet> fragment(Packet* pdu);



struct PPL_pkt_64k : Packet{
    double standard_deviation;  // Standard deviation of data
    double codebook[16];        // Quantization levels
    uint32_t data[2048];        // compressed PPL data
};
