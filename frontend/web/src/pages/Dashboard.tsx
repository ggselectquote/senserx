import { AppBar, Box, Toolbar, Typography } from '@mui/material';
import * as React from 'react';
import ActivityListItem from '../components/ActivityListItem';
//import { useFacilitiesQuery } from '../queries/useFacilitiesQuery';
import FacilityListItem from '../components/FacilityListItem';
import type { Facility, InventoryEvent } from '../types/types.ts';

const Dashboard = () => {
    // const { data: facilities } = useFacilitiesQuery();
    // const { data: updates } = useActivityQuery("");

    const facilities : Facility[] = [{
        name: "Facility 1",
        contact: "Greg",
		address: "a",
		uid: "123",
        layoutIds: ["9b5a1a77-a5b3-4b86-9066-99a7a30b8ac3", "a3e4ae77-c38b-4b01-a085-8e19c7e10770"]
	},
	{
		name: "Facility 2",
        contact: "Andrew",
		address: "a",
        uid: "456",
        layoutIds: ["", ""]
	}];
    const updates: InventoryEvent[] = [{
		uid: "01",
		eventType: "dispense",
        timestamp: 1691622800000,
        upc: "7423721512",
        quantity: 10,
        isConfirmed: true,
        facilityId: "002",
        facilityLayoutId: "005",
        shelfId: "008",
	},
    {
        uid: "02",
        eventType: "receive",
        timestamp: 1691621800000,
        upc: "8423791513",
        quantity: 150,
        isConfirmed: true,
        facilityId: "001",
        facilityLayoutId: "004",
        shelfId: "007",
    },
	{
		uid: "01",
		eventType: "dispense",
        timestamp: 1691623800000,
        upc: "6423701511",
        quantity: 25,
        isConfirmed: false,
        facilityId: "003",
        facilityLayoutId: "006",
        shelfId: "009",
    }];

    return (
        <>
            <Box
				sx={{
					display: 'flex',
					flexDirection: 'row',
					maxHeight: '100%',
					height: '100%',
					width: '100%',
				}}
            >
                <AppBar
                    position="fixed"
                    sx={{
                        backgroundColor: 'green'
                    }}
                    elevation={1}
                >
                    <Toolbar>
                        <Box
                            sx={{
                                display: 'flex',
                                alignItems: 'center',
                            }}
                        >
                            <Typography variant="h6">
                                SenseRx
                            </Typography>
                        </Box>
                    </Toolbar>
                </AppBar> 
                <Box
                    sx={{
                        mt: 8,
                        p: 2,
                        height: '100%',
                        flex: 1,
                    }}
                >
                    {facilities &&
                        facilities!.map((facility) => (
                            // <FacilityRow
                            //     key={facility.uid}
                            //     facility={facility}
                            // />
                            <FacilityListItem
                                key={facility.uid}
                                facility={facility}
                            />
                        ))}
                    <Box sx={{ mt: 2, mb: 2 }}>
                        <Typography variant="h6">Update Log</Typography>                        
                    </Box>
                    <Box sx={{
                        display: 'flex',
                        flexDirection: 'column',
                        ml: 2,
                        p: 0,
                    }} component='ul'>
                    {updates &&
                        updates.sort(u => u.timestamp)!.map((update) => (
                            <ActivityListItem
                                key={update.eventType + '_' + update.upc + '_' + update.timestamp}
                                event={update}
                            />
                        ))}
                    </Box>
                </Box>   
            </Box>
        </>       
    )
};

export default Dashboard;
