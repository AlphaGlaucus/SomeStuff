/*

	DU3456SEM.H

	DB

	Mlaskal's semantic interface for DU3-6

*/

#ifndef DU3456SEM_H
#define DU3456SEM_H

#include <climits>
#include <string>
#include <regex>
#include "literal_storage.hpp"
#include "flat_icblock.hpp"
#include "dutables.hpp"
#include "abstract_instr.hpp"
#include "gen_ainstr.hpp"

namespace mlc {

	std::string GetNumberFromWrongNumber(std::string wrongNumber, std::regex reg, std::string raplacement);

	struct vys {
		mlc::icblock_pointer bpoint;
		mlc::type_category tc;
	};

	struct Eplmin {
		bool b;
		mlc::DUTOKGE_OPER_SIGNADD sign;
	};

	struct vc {
		std::vector<mlc::ls_id_index> ids;
	};

	struct real_params {
		mlc::icblock_pointer bpoint;
		std::vector<mlc::type_category> param_types;
	};
}

#endif

